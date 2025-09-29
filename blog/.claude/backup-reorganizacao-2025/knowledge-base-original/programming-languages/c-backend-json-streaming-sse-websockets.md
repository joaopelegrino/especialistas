Excelente pergunta! Para um backend C puro, o frontend precisa de estratégias específicas para lidar com transmissão assíncrona e protocols modernos. Vou detalhar as opções:

## 🌊 **JSON Streaming com C Backend**

### **Server-Sent Events (SSE) - Simples e Eficaz**

```c
// Backend C - SSE para dados médicos em tempo real
#include <microhttpd.h>
#include <json-c/json.h>

static enum MHD_Result stream_medical_data(void *cls,
                                          uint64_t pos,
                                          char *buf,
                                          size_t max) {
    struct medical_stream_context *ctx = cls;
    
    if (ctx->current_record < ctx->total_records) {
        // Cria JSON para próximo registro médico
        json_object *record = json_object_new_object();
        json_object *patient_id = json_object_new_string(ctx->records[ctx->current_record].patient_id);
        json_object *vitals = json_object_new_object();
        
        // Adiciona sinais vitais em tempo real
        json_object_object_add(vitals, "heart_rate", 
            json_object_new_int(ctx->records[ctx->current_record].heart_rate));
        json_object_object_add(vitals, "blood_pressure", 
            json_object_new_string(ctx->records[ctx->current_record].bp));
        
        json_object_object_add(record, "patient_id", patient_id);
        json_object_object_add(record, "vitals", vitals);
        json_object_object_add(record, "timestamp", 
            json_object_new_int64(time(NULL)));
        
        // Formata como SSE
        const char *json_str = json_object_to_json_string(record);
        int written = snprintf(buf, max, 
            "data: %s\n\n", json_str);
        
        json_object_put(record);
        ctx->current_record++;
        
        return written;
    }
    
    return MHD_CONTENT_READER_END_OF_STREAM;
}

// Endpoint SSE
static enum MHD_Result handle_medical_stream(struct MHD_Connection *connection,
                                           const char *url,
                                           const char *method,
                                           const char *version,
                                           const char *upload_data,
                                           size_t *upload_data_size,
                                           void **con_cls) {
    
    if (strcmp(url, "/api/medical-stream") != 0) {
        return MHD_NO;
    }
    
    struct medical_stream_context *ctx = malloc(sizeof(struct medical_stream_context));
    // Inicializa contexto com dados médicos...
    
    struct MHD_Response *response = MHD_create_response_from_callback(
        MHD_SIZE_UNKNOWN, 1024, stream_medical_data, ctx, free_stream_context);
    
    // Headers para SSE
    MHD_add_response_header(response, "Content-Type", "text/event-stream");
    MHD_add_response_header(response, "Cache-Control", "no-cache");
    MHD_add_response_header(response, "Connection", "keep-alive");
    MHD_add_response_header(response, "Access-Control-Allow-Origin", "*");
    
    enum MHD_Result ret = MHD_queue_response(connection, MHD_HTTP_OK, response);
    MHD_destroy_response(response);
    
    return ret;
}
```

### **Frontend JavaScript - Consumindo SSE**

```javascript
// Frontend - Recebendo dados médicos em tempo real
class MedicalDataStream {
    constructor(apiUrl) {
        this.apiUrl = apiUrl;
        this.eventSource = null;
        this.callbacks = new Map();
    }
    
    startStream(patientId) {
        const url = `${this.apiUrl}/api/medical-stream?patient=${patientId}`;
        
        this.eventSource = new EventSource(url);
        
        this.eventSource.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data);
                this.handleMedicalData(data);
            } catch (error) {
                console.error('Erro parsing JSON:', error);
            }
        };
        
        this.eventSource.onerror = (error) => {
            console.error('SSE Error:', error);
            // Reconecta automaticamente
            setTimeout(() => this.startStream(patientId), 5000);
        };
    }
    
    handleMedicalData(data) {
        // Atualiza UI em tempo real
        if (data.vitals) {
            this.updateVitalsDisplay(data.vitals);
        }
        
        // Notifica callbacks registrados
        this.callbacks.forEach(callback => callback(data));
    }
    
    onData(callback) {
        this.callbacks.set(callback.name || Date.now(), callback);
    }
    
    stopStream() {
        if (this.eventSource) {
            this.eventSource.close();
            this.eventSource = null;
        }
    }
}

// Uso em aplicação React/Vue
const medicalStream = new MedicalDataStream('http://localhost:8080');

// Em componente React
useEffect(() => {
    medicalStream.startStream(patientId);
    
    medicalStream.onData((data) => {
        setVitals(data.vitals);
        setLastUpdate(data.timestamp);
    });
    
    return () => medicalStream.stopStream();
}, [patientId]);
```

---

## 🔄 **JSON-RPC com C Backend**

### **Implementação JSON-RPC em C**

```c
// Backend C - JSON-RPC para operações médicas
#include <json-c/json.h>
#include <cjson/cJSON.h>

typedef struct {
    char method[64];
    json_object *params;
    json_object *id;
} jsonrpc_request_t;

typedef struct {
    json_object *result;
    json_object *error;
    json_object *id;
} jsonrpc_response_t;

// Processa requisição JSON-RPC
static jsonrpc_response_t* process_jsonrpc_request(const char *request_str) {
    json_object *request = json_tokener_parse(request_str);
    jsonrpc_response_t *response = calloc(1, sizeof(jsonrpc_response_t));
    
    // Parse request
    json_object *method_obj, *params_obj, *id_obj;
    json_object_object_get_ex(request, "method", &method_obj);
    json_object_object_get_ex(request, "params", &params_obj);
    json_object_object_get_ex(request, "id", &id_obj);
    
    const char *method = json_object_get_string(method_obj);
    response->id = json_object_get(id_obj); // Incrementa ref count
    
    // Dispatch para handlers específicos
    if (strcmp(method, "get_patient_records") == 0) {
        response->result = get_patient_records_handler(params_obj);
    } else if (strcmp(method, "update_vital_signs") == 0) {
        response->result = update_vital_signs_handler(params_obj);
    } else if (strcmp(method, "encrypt_medical_data") == 0) {
        response->result = encrypt_medical_data_handler(params_obj);
    } else {
        // Método não encontrado
        response->error = create_jsonrpc_error(-32601, "Method not found", NULL);
    }
    
    json_object_put(request);
    return response;
}

// Handler específico para registros de pacientes
static json_object* get_patient_records_handler(json_object *params) {
    json_object *patient_id_obj;
    json_object_object_get_ex(params, "patient_id", &patient_id_obj);
    
    const char *patient_id = json_object_get_string(patient_id_obj);
    
    // Busca registros no banco (com criptografia pós-quântica)
    medical_record_t *records;
    int count = get_encrypted_records(patient_id, &records);
    
    // Cria resposta JSON
    json_object *result = json_object_new_object();
    json_object *records_array = json_object_new_array();
    
    for (int i = 0; i < count; i++) {
        json_object *record = json_object_new_object();
        
        // Descriptografa dados sensíveis
        char *decrypted_data = decrypt_medical_data(records[i].encrypted_data);
        
        json_object_object_add(record, "record_id", 
            json_object_new_string(records[i].record_id));
        json_object_object_add(record, "data", 
            json_object_new_string(decrypted_data));
        json_object_object_add(record, "created_at", 
            json_object_new_int64(records[i].created_at));
        
        json_object_array_add(records_array, record);
        
        free(decrypted_data);
    }
    
    json_object_object_add(result, "records", records_array);
    json_object_object_add(result, "total", json_object_new_int(count));
    
    free(records);
    return result;
}

// HTTP handler para JSON-RPC
static enum MHD_Result handle_jsonrpc(struct MHD_Connection *connection,
                                     const char *url,
                                     const char *method,
                                     const char *version,
                                     const char *upload_data,
                                     size_t *upload_data_size,
                                     void **con_cls) {
    
    if (strcmp(url, "/api/jsonrpc") != 0) {
        return MHD_NO;
    }
    
    if (strcmp(method, "POST") != 0) {
        return MHD_NO;
    }
    
    // Processa dados POST
    if (*upload_data_size > 0) {
        jsonrpc_response_t *response = process_jsonrpc_request(upload_data);
        
        // Cria JSON response
        json_object *response_obj = json_object_new_object();
        json_object_object_add(response_obj, "jsonrpc", json_object_new_string("2.0"));
        
        if (response->result) {
            json_object_object_add(response_obj, "result", response->result);
        }
        if (response->error) {
            json_object_object_add(response_obj, "error", response->error);
        }
        if (response->id) {
            json_object_object_add(response_obj, "id", response->id);
        }
        
        const char *response_str = json_object_to_json_string(response_obj);
        
        struct MHD_Response *http_response = MHD_create_response_from_buffer(
            strlen(response_str), (void*)response_str, MHD_RESPMEM_MUST_COPY);
        
        MHD_add_response_header(http_response, "Content-Type", "application/json");
        
        enum MHD_Result ret = MHD_queue_response(connection, MHD_HTTP_OK, http_response);
        
        json_object_put(response_obj);
        free(response);
        MHD_destroy_response(http_response);
        
        *upload_data_size = 0;
        return ret;
    }
    
    return MHD_YES;
}
```

### **Cliente JavaScript JSON-RPC**

```javascript
// Frontend - Cliente JSON-RPC para sistema médico
class MedicalAPI {
    constructor(endpoint) {
        this.endpoint = endpoint;
        this.requestId = 0;
    }
    
    async call(method, params = {}) {
        const request = {
            jsonrpc: "2.0",
            method: method,
            params: params,
            id: ++this.requestId
        };
        
        const response = await fetch(this.endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(request)
        });
        
        const data = await response.json();
        
        if (data.error) {
            throw new Error(`RPC Error: ${data.error.message}`);
        }
        
        return data.result;
    }
    
    // Métodos específicos para sistema médico
    async getPatientRecords(patientId) {
        return await this.call('get_patient_records', {
            patient_id: patientId
        });
    }
    
    async updateVitalSigns(patientId, vitals) {
        return await this.call('update_vital_signs', {
            patient_id: patientId,
            vitals: vitals,
            timestamp: Date.now()
        });
    }
    
    async encryptMedicalData(data, encryptionLevel) {
        return await this.call('encrypt_medical_data', {
            data: data,
            encryption_level: encryptionLevel,
            algorithm: 'ML-KEM-768' // Algoritmo pós-quântico
        });
    }
    
    // Batch operations para eficiência
    async batchCall(requests) {
        const batchRequest = requests.map((req, index) => ({
            jsonrpc: "2.0",
            method: req.method,
            params: req.params,
            id: ++this.requestId + index
        }));
        
        const response = await fetch(this.endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(batchRequest)
        });
        
        return await response.json();
    }
}

// Uso em aplicação
const medicalAPI = new MedicalAPI('/api/jsonrpc');

// React Hook para dados médicos
function useMedicalRecords(patientId) {
    const [records, setRecords] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    
    useEffect(() => {
        let mounted = true;
        
        const loadRecords = async () => {
            try {
                setLoading(true);
                const data = await medicalAPI.getPatientRecords(patientId);
                
                if (mounted) {
                    setRecords(data.records);
                    setError(null);
                }
            } catch (err) {
                if (mounted) {
                    setError(err.message);
                }
            } finally {
                if (mounted) {
                    setLoading(false);
                }
            }
        };
        
        if (patientId) {
            loadRecords();
        }
        
        return () => { mounted = false; };
    }, [patientId]);
    
    return { records, loading, error };
}
```

---

## ⚡ **gRPC com C Backend**

### **Definição Protocol Buffer**

```protobuf
// medical_service.proto
syntax = "proto3";

package medical;

service MedicalService {
    // Unary RPC
    rpc GetPatientRecord(PatientRequest) returns (PatientRecord);
    
    // Server streaming para monitoramento em tempo real
    rpc StreamVitalSigns(PatientRequest) returns (stream VitalSigns);
    
    // Client streaming para upload de dados
    rpc UploadMedicalData(stream MedicalData) returns (UploadResponse);
    
    // Bidirectional streaming para telemedicina
    rpc TelemedicineSession(stream TelemedicineMessage) returns (stream TelemedicineMessage);
}

message PatientRequest {
    string patient_id = 1;
    string access_token = 2;
    int64 timestamp = 3;
}

message PatientRecord {
    string patient_id = 1;
    string encrypted_data = 2; // Dados criptografados com algoritmo pós-quântico
    repeated MedicalRecord records = 3;
    int64 created_at = 4;
}

message VitalSigns {
    string patient_id = 1;
    int32 heart_rate = 2;
    string blood_pressure = 3;
    float temperature = 4;
    int32 oxygen_saturation = 5;
    int64 timestamp = 6;
    string device_id = 7;
}

message MedicalData {
    string patient_id = 1;
    bytes encrypted_content = 2;
    string content_type = 3;
    string encryption_algorithm = 4; // "ML-KEM-768", "ML-DSA-65", etc.
    int64 timestamp = 5;
}
```

### **Implementação C do servidor gRPC**

```c
// medical_server.c - Servidor gRPC em C
#include <grpc/grpc.h>
#include <grpc/impl/propagation_bits.h>
#include <grpc/slice.h>
#include <grpc/support/log.h>
#include <grpc/support/time.h>
#include <grpc/grpc_cronet.h>
#include "medical_service.grpc.pb.h"
#include <oqs/oqs.h>

typedef struct {
    grpc_completion_queue* cq;
    Medical_MedicalService_AsyncService* service;
    grpc_server* server;
    OQS_KEM* kem;
    OQS_SIG* sig;
} medical_server_t;

// Handler para streaming de sinais vitais
static void handle_stream_vital_signs(grpc_server_context* ctx,
                                     const medical_PatientRequest* request,
                                     grpc_ServerWriter<medical_VitalSigns>* writer) {
    
    const char* patient_id = medical_PatientRequest_patient_id(request);
    
    // Valida acesso do paciente
    if (!validate_patient_access(patient_id, medical_PatientRequest_access_token(request))) {
        grpc_status_code_PERMISSION_DENIED;
        return;
    }
    
    // Stream de dados em tempo real
    medical_VitalSigns vital_signs;
    medical_VitalSigns_init(&vital_signs);
    
    while (ctx->IsCancelled() == false) {
        // Lê dados dos sensores médicos
        vital_signs_data_t current_vitals;
        if (read_patient_vitals(patient_id, &current_vitals) == 0) {
            
            // Preenche mensagem protobuf
            medical_VitalSigns_set_patient_id(&vital_signs, patient_id);
            medical_VitalSigns_set_heart_rate(&vital_signs, current_vitals.heart_rate);
            medical_VitalSigns_set_blood_pressure(&vital_signs, current_vitals.blood_pressure);
            medical_VitalSigns_set_temperature(&vital_signs, current_vitals.temperature);
            medical_VitalSigns_set_oxygen_saturation(&vital_signs, current_vitals.oxygen_saturation);
            medical_VitalSigns_set_timestamp(&vital_signs, time(NULL));
            medical_VitalSigns_set_device_id(&vital_signs, current_vitals.device_id);
            
            // Envia dados para cliente
            if (!writer->Write(vital_signs)) {
                break; // Cliente desconectou
            }
        }
        
        // Aguarda próxima leitura (1 segundo)
        usleep(1000000);
    }
    
    medical_VitalSigns_free(&vital_signs);
}

// Handler para upload de dados médicos (client streaming)
static grpc_Status handle_upload_medical_data(grpc_server_context* ctx,
                                             grpc_ServerReader<medical_MedicalData>* reader,
                                             medical_UploadResponse* response) {
    
    medical_MedicalData data;
    size_t total_uploaded = 0;
    int file_count = 0;
    
    // Inicializa contexto de criptografia pós-quântica
    OQS_KEM* kem = OQS_KEM_new("ML-KEM-768");
    if (!kem) {
        return grpc_Status(grpc_status_code_INTERNAL, "Failed to initialize quantum-safe encryption");
    }
    
    // Lê stream de dados
    while (reader->Read(&data)) {
        const char* patient_id = medical_MedicalData_patient_id(&data);
        
        // Valida e descriptografa dados
        const char* algorithm = medical_MedicalData_encryption_algorithm(&data);
        const uint8_t* encrypted_content = medical_MedicalData_encrypted_content(&data);
        size_t content_length = medical_MedicalData_encrypted_content_len(&data);
        
        // Processa dados com algoritmo pós-quântico apropriado
        uint8_t* decrypted_data;
        size_t decrypted_length;
        
        if (strcmp(algorithm, "ML-KEM-768") == 0) {
            if (decrypt_with_kyber(encrypted_content, content_length, 
                                 &decrypted_data, &decrypted_length) != 0) {
                OQS_KEM_free(kem);
                return grpc_Status(grpc_status_code_INVALID_ARGUMENT, "Decryption failed");
            }
        }
        
        // Armazena dados descriptografados de forma segura
        if (store_medical_data_secure(patient_id, decrypted_data, decrypted_length) == 0) {
            total_uploaded += decrypted_length;
            file_count++;
        }
        
        // Limpa dados sensíveis da memória
        explicit_bzero(decrypted_data, decrypted_length);
        free(decrypted_data);
        
        medical_MedicalData_free(&data);
    }
    
    // Prepara resposta
    medical_UploadResponse_set_success(response, true);
    medical_UploadResponse_set_files_uploaded(response, file_count);
    medical_UploadResponse_set_total_bytes(response, total_uploaded);
    
    OQS_KEM_free(kem);
    return grpc_Status_OK;
}

// Inicialização do servidor
int main() {
    grpc_init();
    
    medical_server_t server;
    server.cq = grpc_completion_queue_create(GRPC_CQ_NEXT, GRPC_CQ_DEFAULT_POLLING, NULL);
    
    // Configura servidor gRPC com TLS pós-quântico
    grpc_server_credentials* creds = grpc_ssl_server_credentials_create_ex(
        NULL, NULL, 0, GRPC_SSL_DONT_REQUEST_CLIENT_CERTIFICATE, NULL);
    
    grpc_arg args[] = {
        {GRPC_ARG_KEEPALIVE_TIME_MS, GRPC_ARG_INTEGER, {.integer = 30000}},
        {GRPC_ARG_KEEPALIVE_TIMEOUT_MS, GRPC_ARG_INTEGER, {.integer = 5000}},
        {GRPC_ARG_HTTP2_MAX_PINGS_WITHOUT_DATA, GRPC_ARG_INTEGER, {.integer = 0}},
        {GRPC_ARG_HTTP2_MIN_PING_INTERVAL_WITHOUT_DATA_MS, GRPC_ARG_INTEGER, {.integer = 300000}},
    };
    
    grpc_channel_args channel_args = {
        .num_args = sizeof(args) / sizeof(args[0]),
        .args = args
    };
    
    server.server = grpc_server_create(&channel_args, NULL);
    
    // Registra serviço
    grpc_server_register_completion_queue(server.server, server.cq, NULL);
    
    int port = grpc_server_add_secure_http2_port(server.server, "0.0.0.0:50051", creds);
    
    if (port == 0) {
        fprintf(stderr, "Failed to bind to port\n");
        return -1;
    }
    
    printf("Medical gRPC Server listening on port %d\n", port);
    
    grpc_server_start(server.server);
    
    // Event loop
    grpc_event event;
    do {
        event = grpc_completion_queue_next(server.cq, 
                                          gpr_inf_future(GPR_CLOCK_REALTIME), NULL);
        
        if (event.type == GRPC_OP_COMPLETE) {
            // Processa operação completada
            handle_grpc_operation(&event);
        }
        
    } while (event.type != GRPC_QUEUE_SHUTDOWN);
    
    // Cleanup
    grpc_server_shutdown_and_notify(server.server, server.cq, NULL);
    grpc_completion_queue_shutdown(server.cq);
    grpc_completion_queue_destroy(server.cq);
    grpc_server_destroy(server.server);
    grpc_shutdown();
    
    return 0;
}
```

### **Cliente gRPC Web (Frontend)**

```javascript
// Frontend - Cliente gRPC-Web
import { MedicalServiceClient } from './medical_service_grpc_web_pb';
import { PatientRequest, VitalSigns } from './medical_service_pb';

class MedicalGRPCClient {
    constructor(endpoint) {
        this.client = new MedicalServiceClient(endpoint);
    }
    
    // Stream de sinais vitais em tempo real
    streamVitalSigns(patientId, onData, onError, onEnd) {
        const request = new PatientRequest();
        request.setPatientId(patientId);
        request.setAccessToken(this.getAuthToken());
        request.setTimestamp(Date.now());
        
        const stream = this.client.streamVitalSigns(request);
        
        stream.on('data', (response) => {
            const vitals = {
                patientId: response.getPatientId(),
                heartRate: response.getHeartRate(),
                bloodPressure: response.getBloodPressure(),
                temperature: response.getTemperature(),
                oxygenSaturation: response.getOxygenSaturation(),
                timestamp: response.getTimestamp(),
                deviceId: response.getDeviceId()
            };
            
            onData(vitals);
        });
        
        stream.on('error', onError);
        stream.on('end', onEnd);
        
        return stream;
    }
    
    // Upload de dados médicos
    async uploadMedicalData(patientId, files) {
        return new Promise((resolve, reject) => {
            const stream = this.client.uploadMedicalData((error, response) => {
                if (error) {
                    reject(error);
                } else {
                    resolve({
                        success: response.getSuccess(),
                        filesUploaded: response.getFilesUploaded(),
                        totalBytes: response.getTotalBytes()
                    });
                }
            });
            
            // Envia arquivos um por um
            files.forEach(async (file) => {
                const encrypted = await this.encryptWithQuantumSafe(file.data);
                
                const medicalData = new MedicalData();
                medicalData.setPatientId(patientId);
                medicalData.setEncryptedContent(encrypted);
                medicalData.setContentType(file.type);
                medicalData.setEncryptionAlgorithm('ML-KEM-768');
                medicalData.setTimestamp(Date.now());
                
                stream.write(medicalData);
            });
            
            stream.end();
        });
    }
    
    async encryptWithQuantumSafe(data) {
        // Implementação seria via WebAssembly ou Web Crypto API
        // com bibliotecas pós-quânticas
        return data; // Placeholder
    }
}

// React Hook para sinais vitais em tempo real
function useVitalSigns(patientId) {
    const [vitals, setVitals] = useState(null);
    const [connected, setConnected] = useState(false);
    const [error, setError] = useState(null);
    
    useEffect(() => {
        if (!patientId) return;
        
        const client = new MedicalGRPCClient('/api/grpc');
        
        const stream = client.streamVitalSigns(
            patientId,
            (data) => {
                setVitals(data);
                setConnected(true);
                setError(null);
            },
            (err) => {
                setError(err.message);
                setConnected(false);
            },
            () => {
                setConnected(false);
            }
        );
        
        return () => {
            if (stream) {
                stream.cancel();
            }
        };
    }, [patientId]);
    
    return { vitals, connected, error };
}
```

---

## 🌐 **WebAssembly - A Opção Revolucionária**

### **C Compilado para WASM no Frontend**

```c
// medical_wasm.c - Lógica médica compilada para WebAssembly
#include <emscripten.h>
#include <stdlib.h>
#include <string.h>
#include <oqs/oqs.h>

// Estrutura para dados médicos
typedef struct {
    char patient_id[64];
    int heart_rate;
    char blood_pressure[16];
    float temperature;
    int oxygen_saturation;
    long timestamp;
} vital_signs_t;

// Exporta função para JavaScript
EMSCRIPTEN_KEEPALIVE
char* encrypt_medical_data(const char* data, size_t data_len) {
    // Inicializa algoritmo pós-quântico
    OQS_KEM* kem = OQS_KEM_new("ML-KEM-768");
    if (!kem) {
        return NULL;
    }
    
    // Gera par de chaves
    uint8_t public_key[OQS_KEM_ml_kem_768_length_public_key];
    uint8_t secret_key[OQS_KEM_ml_kem_768_length_secret_key];
    
    if (OQS_KEM_keypair(kem, public_key, secret_key) != OQS_SUCCESS) {
        OQS_KEM_free(kem);
        return NULL;
    }
    
    // Encapsula chave
    uint8_t ciphertext[OQS_KEM_ml_kem_768_length_ciphertext];
    uint8_t shared_secret[OQS_KEM_ml_kem_768_length_shared_secret];
    
    if (OQS_KEM_encaps(kem, ciphertext, shared_secret, public_key) != OQS_SUCCESS) {
        OQS_KEM_free(kem);
        return NULL;
    }
    
    // Aloca memória para resultado (será liberada pelo JavaScript)
    size_t result_len = OQS_KEM_ml_kem_768_length_ciphertext + data_len + 1;
    char* result = malloc(result_len);
    
    // Combina ciphertext + dados (simplificado)
    memcpy(result, ciphertext, OQS_KEM_ml_kem_768_length_ciphertext);
    memcpy(result + OQS_KEM_ml_kem_768_length_ciphertext, data, data_len);
    result[result_len - 1] = '\0';
    
    OQS_KEM_free(kem);
    return result;
}

EMSCRIPTEN_KEEPALIVE
int validate_vital_signs(vital_signs_t* vitals) {
    // Validação de sinais vitais
    if (vitals->heart_rate < 40 || vitals->heart_rate > 200) {
        return 0; // Frequência cardíaca anormal
    }
    
    if (vitals->temperature < 35.0 || vitals->temperature > 42.0) {
        return 0; // Temperatura corporal anormal
    }
    
    if (vitals->oxygen_saturation < 70 || vitals->oxygen_saturation > 100) {
        return 0; // Saturação de oxigênio anormal
    }
    
    return 1; // Valores normais
}

EMSCRIPTEN_KEEPALIVE
char* process_medical_algorithm(const char* input_json) {
    // Processa dados médicos com algoritmos complexos
    // Implementação de algoritmos proprietários em C
    // para performance máxima no frontend
    
    // Parse JSON input (usando cJSON ou similar)
    // Aplica algoritmos médicos
    // Retorna resultado JSON
    
    char* result = malloc(256);
    strcpy(result, "{\"status\":\"processed\",\"confidence\":0.95}");
    return result;
}

// Função para liberar memória alocada
EMSCRIPTEN_KEEPALIVE
void free_wasm_memory(void* ptr) {
    free(ptr);
}
```

### **Compilação para WebAssembly**

```bash
# Compila para WebAssembly com Emscripten
emcc medical_wasm.c \
     -I/usr/local/include/oqs \
     -L/usr/local/lib \
     -loqs \
     -s WASM=1 \
     -s EXPORTED_FUNCTIONS='["_encrypt_medical_data","_validate_vital_signs","_process_medical_algorithm","_free_wasm_memory"]' \
     -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap","UTF8ToString","stringToUTF8"]' \
     -s ALLOW_MEMORY_GROWTH=1 \
     -s MODULARIZE=1 \
     -s EXPORT_NAME='MedicalWASM' \
     -o medical_wasm.js
```

### **Integração JavaScript**

```javascript
// Frontend - Usando WASM module
class MedicalWASMProcessor {
    constructor() {
        this.wasmModule = null;
        this.ready = false;
    }
    
    async initialize() {
        // Carrega módulo WebAssembly
        this.wasmModule = await MedicalWASM();
        this.ready = true;
        
        // Wrapa funções C para JavaScript
        this.encryptMedicalData = this.wasmModule.cwrap(
            'encrypt_medical_data', 
            'string', 
            ['string', 'number']
        );
        
        this.validateVitalSigns = this.wasmModule.cwrap(
            'validate_vital_signs',
            'number',
            ['number'] // Pointer para struct
        );
        
        this.processMedicalAlgorithm = this.wasmModule.cwrap(
            'process_medical_algorithm',
            'string',
            ['string']
        );
        
        this.freeWasmMemory = this.wasmModule.cwrap(
            'free_wasm_memory',
            'void',
            ['number']
        );
    }
    
    // Encripta dados médicos com algoritmo pós-quântico
    async encryptData(data) {
        if (!this.ready) await this.initialize();
        
        const dataStr = JSON.stringify(data);
        const encrypted = this.encryptMedicalData(dataStr, dataStr.length);
        
        return encrypted;
    }
    
    // Valida sinais vitais usando lógica C
    validateVitals(vitals) {
        if (!this.ready) return false;
        
        // Aloca struct na memória WASM
        const structSize = 84; // sizeof(vital_signs_t)
        const structPtr = this.wasmModule._malloc(structSize);
        
        // Preenche struct
        const heap = new Uint8Array(this.wasmModule.HEAPU8.buffer, structPtr, structSize);
        const encoder = new TextEncoder();
        
        // patient_id (64 bytes)
        const patientIdBytes = encoder.encode(vitals.patientId.padEnd(63, '\0'));
        heap.set(patientIdBytes.slice(0, 64), 0);
        
        // heart_rate (int, 4 bytes)
        const heartRateView = new Int32Array(this.wasmModule.HEAPU8.buffer, structPtr + 64, 1);
        heartRateView[0] = vitals.heartRate;
        
        // blood_pressure (16 bytes)
        const bpBytes = encoder.encode(vitals.bloodPressure.padEnd(15, '\0'));
        heap.set(bpBytes.slice(0, 16), 68);
        
        // temperature (float, 4 bytes)
        const tempView = new Float32Array(this.wasmModule.HEAPU8.buffer, structPtr + 84, 1);
        tempView[0] = vitals.temperature;
        
        // oxygen_saturation (int, 4 bytes)
        const o2View = new Int32Array(this.wasmModule.HEAPU8.buffer, structPtr + 88, 1);
        o2View[0] = vitals.oxygenSaturation;
        
        // timestamp (long, 8 bytes)
        const timestampView = new BigInt64Array(this.wasmModule.HEAPU8.buffer, structPtr + 92, 1);
        timestampView[0] = BigInt(vitals.timestamp);
        
        // Chama função C
        const isValid = this.validateVitalSigns(structPtr);
        
        // Libera memória
        this.wasmModule._free(structPtr);
        
        return isValid === 1;
    }
    
    // Processa algoritmos médicos complexos
    async processAlgorithm(inputData) {
        if (!this.ready) await this.initialize();
        
        const inputJson = JSON.stringify(inputData);
        const resultPtr = this.processMedicalAlgorithm(inputJson);
        
        // Converte resultado C string para JavaScript
        const resultStr = this.wasmModule.UTF8ToString(resultPtr);
        
        // Libera memória alocada em C
        this.freeWasmMemory(resultPtr);
        
        return JSON.parse(resultStr);
    }
}

// React Hook para processamento WASM
function useMedicalWASM() {
    const [processor, setProcessor] = useState(null);
    const [loading, setLoading] = useState(true);
    
    useEffect(() => {
        const initWASM = async () => {
            const wasmProcessor = new MedicalWASMProcessor();
            await wasmProcessor.initialize();
            setProcessor(wasmProcessor);
            setLoading(false);
        };
        
        initWASM();
    }, []);
    
    return { processor, loading };
}

// Componente React usando WASM
function VitalSignsValidator({ vitals }) {
    const { processor, loading } = useMedicalWASM();
    const [isValid, setIsValid] = useState(null);
    
    useEffect(() => {
        if (processor && vitals) {
            const valid = processor.validateVitals(vitals);
            setIsValid(valid);
        }
    }, [processor, vitals]);
    
    if (loading) return <div>Carregando validador WASM...</div>;
    
    return (
        <div className={`vitals-status ${isValid ? 'valid' : 'invalid'}`}>
            <h3>Sinais Vitais</h3>
            <p>Status: {isValid ? '✓ Normais' : '⚠️ Anormais'}</p>
            <p>Frequência Cardíaca: {vitals.heartRate} bpm</p>
            <p>Pressão Arterial: {vitals.bloodPressure}</p>
            <p>Temperatura: {vitals.temperature}°C</p>
            <p>Saturação O₂: {vitals.oxygenSaturation}%</p>
        </div>
    );
}
```

---

## 🏗️ **Arquitetura Recomendada Híbrida**

### **Stack Completa: C Backend + Frontend Moderno**

```
┌─────────────────────────────────────────────────────────────────────┐
│                     FRONTEND LAYERS                                  │
├─────────────────────────────────────────────────────────────────────┤
│  React/Vue.js UI Components                                         │
│  ├── Real-time dashboards                                           │
│  ├── Medical forms and validations                                  │
│  └── Patient management interface                                   │
├─────────────────────────────────────────────────────────────────────┤
│  WASM Layer (C Medical Logic)                                       │
│  ├── Quantum-safe cryptography (LibOQS)                            │
│  ├── Medical algorithm processing                                   │
│  ├── Vital signs validation                                         │
│  └── Data compression/decompression                                 │
├─────────────────────────────────────────────────────────────────────┤
│  Communication Layer                                                │
│  ├── WebSocket/SSE for real-time data                              │
│  ├── gRPC-Web for complex operations                               │
│  ├── JSON-RPC for standard API calls                               │
│  └── File upload/download with progress                            │
├─────────────────────────────────────────────────────────────────────┤
│                     BACKEND LAYERS (C)                              │
├─────────────────────────────────────────────────────────────────────┤
│  HTTP/gRPC Server (C)                                              │
│  ├── libmicrohttpd or Kore framework                               │
│  ├── gRPC C++ with health checks                                   │
│  ├── TLS 1.3 with post-quantum ciphers                            │
│  └── Load balancing and failover                                   │
├─────────────────────────────────────────────────────────────────────┤
│  Business Logic Layer (C)                                          │
│  ├── Medical record processing                                     │
│  ├── FHIR/HL7 message handling                                     │
│  ├── Compliance validation (LGPD/HIPAA)                           │
│  └── Multi-tenant data isolation                                   │
├─────────────────────────────────────────────────────────────────────┤
│  Cryptography Layer (C + LibOQS)                                   │
│  ├── ML-KEM for key encapsulation                                  │
│  ├── ML-DSA for digital signatures                                 │
│  ├── AES-256-GCM for symmetric encryption                          │
│  └── Key rotation and HSM integration                              │
├─────────────────────────────────────────────────────────────────────┤
│  Database Layer                                                    │
│  ├── PostgreSQL with Row Level Security                           │
│  ├── Encrypted columns with tenant isolation                      │
│  ├── Audit trail with immutable logs                              │
│  └── Backup with quantum-safe encryption                          │
└─────────────────────────────────────────────────────────────────────┘
```

### **Vantagens desta Arquitetura**

**Performance Máxima:**
- **C backend**: Latência <1ms para operações críticas
- **WASM frontend**: Processamento local sem round-trips
- **Streaming protocols**: Dados em tempo real sem polling

**Segurança Extrema:**
- **Criptografia pós-quântica**: Proteção contra ameaças futuras
- **Isolamento multi-tenant**: Zero cross-contamination
- **Memory safety**: WASM sandbox + análise estática C

**Experiência do Usuário:**
- **Responsividade**: Processamento local + cache inteligente
- **Offline capability**: WASM permite operação sem conexão
- **Real-time updates**: SSE/WebSocket para dados ao vivo

---

## 🎯 **Conclusão e Recomendação Final**

Para um backend C puro com necessidades de transmissão em tempo real, a **combinação recomendada** é:

### **🥇 Solução Ideal: Híbrida Multi-Protocol**

1. **SSE para monitoramento médico**: Simples, confiável, reconecção automática
2. **gRPC para operações complexas**: Bi-directional streaming, schema forte
3. **WebAssembly para lógica crítica**: Performance C no frontend, algoritmos proprietários protegidos
4. **JSON-RPC para APIs padrão**: Compatibilidade universal, fácil debug

### **🥈 Alternativa Simples: SSE + JSON**

Se a complexidade for uma preocupação:
- **Server-Sent Events** para dados em tempo real
- **Fetch API** com JSON para operações CRUD
- **WebAssembly** apenas para criptografia pós-quântica

### **🥉 Solução Mínima: REST + WebSocket**

Para protótipos rápidos:
- **WebSocket** para real-time
- **REST JSON** para operações básicas
- **C backend** com libmicrohttpd

**WebAssembly é definitivamente uma opção poderosa** - permite executar a mesma lógica C no frontend e backend, garantindo consistência de algoritmos e performance máxima para operações críticas de saúde.
