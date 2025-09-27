# WebAssembly Healthcare Components - Lab Environment
WASI_SDK = ../../wasi-sdk-20.0/bin
WASM_FILES = build

.PHONY: setup start clean lab-1.1 lab-1.2 lab-1.3

# Environment setup
setup:
	@echo "🏥 Setting up WebAssembly Healthcare Lab Environment..."
	@mkdir -p build src labs
	@echo "✅ Environment ready!"
	@echo "📚 Available commands:"
	@echo "  make start     - Begin first lab"
	@echo "  make lab-1.1   - Hello Medical Component"
	@echo "  make lab-1.2   - Patient Data I/O"
	@echo "  make lab-1.3   - Memory Safety Demo"

# Start learning journey
start: setup lab-1.1

# Lab 1.1: Hello World Medical Component
lab-1.1:
	@echo "🚀 Lab 1.1: Creating Hello Medical Component..."
	@echo '#include <stdio.h>' > src/hello_medical.c
	@echo 'int main() {' >> src/hello_medical.c
	@echo '    printf("🏥 Healthcare WebAssembly Component v1.0\\n");' >> src/hello_medical.c
	@echo '    printf("✅ WASI SDK: Secure medical data processing ready\\n");' >> src/hello_medical.c
	@echo '    return 0;' >> src/hello_medical.c
	@echo '}' >> src/hello_medical.c
	@$(WASI_SDK)/clang src/hello_medical.c -o build/hello_medical.wasm
	@echo "✅ Compiled: build/hello_medical.wasm"
	@echo "🔬 Testing component..."
	@wasmtime build/hello_medical.wasm
	@echo ""
	@echo "📋 Lab 1.1 Complete!"
	@echo "📖 Next: make lab-1.2 (Patient Data I/O)"

# Lab 1.2: WASI File I/O for Patient Data
lab-1.2:
	@echo "🚀 Lab 1.2: Patient Data File I/O..."
	@echo '#include <stdio.h>' > src/patient_data.c
	@echo '#include <string.h>' >> src/patient_data.c
	@echo 'int main() {' >> src/patient_data.c
	@echo '    printf("🏥 Patient Data Handler\\n");' >> src/patient_data.c
	@echo '    FILE *f = fopen("/tmp/patient_001.txt", "w");' >> src/patient_data.c
	@echo '    if (f) {' >> src/patient_data.c
	@echo '        fprintf(f, "Patient ID: [ANONYMIZED]\\n");' >> src/patient_data.c
	@echo '        fprintf(f, "Status: Data processed securely\\n");' >> src/patient_data.c
	@echo '        fclose(f);' >> src/patient_data.c
	@echo '        printf("✅ Patient data written securely\\n");' >> src/patient_data.c
	@echo '    }' >> src/patient_data.c
	@echo '    return 0;' >> src/patient_data.c
	@echo '}' >> src/patient_data.c
	@$(WASI_SDK)/clang src/patient_data.c -o build/patient_data.wasm
	@echo "✅ Compiled: build/patient_data.wasm"
	@echo "🔬 Testing with file access..."
	@wasmtime --dir=/tmp build/patient_data.wasm
	@echo "📄 Created file content:"
	@cat /tmp/patient_001.txt
	@echo ""
	@echo "📋 Lab 1.2 Complete!"
	@echo "📖 Next: make lab-1.3 (Memory Safety)"

# Lab 1.3: Memory Management & Safety
lab-1.3:
	@echo "🚀 Lab 1.3: Memory Safety for Healthcare..."
	@echo '#include <stdio.h>' > src/memory_safety.c
	@echo '#include <stdlib.h>' >> src/memory_safety.c
	@echo '#include <string.h>' >> src/memory_safety.c
	@echo 'int main() {' >> src/memory_safety.c
	@echo '    printf("🔒 Healthcare Memory Safety Demo\\n");' >> src/memory_safety.c
	@echo '    ' >> src/memory_safety.c
	@echo '    // Safe memory allocation for patient records' >> src/memory_safety.c
	@echo '    char *patient_buffer = malloc(256);' >> src/memory_safety.c
	@echo '    if (!patient_buffer) {' >> src/memory_safety.c
	@echo '        printf("❌ Memory allocation failed\\n");' >> src/memory_safety.c
	@echo '        return 1;' >> src/memory_safety.c
	@echo '    }' >> src/memory_safety.c
	@echo '    ' >> src/memory_safety.c
	@echo '    strncpy(patient_buffer, "Sensitive medical data", 255);' >> src/memory_safety.c
	@echo '    patient_buffer[255] = '"'"'\\0'"'"';' >> src/memory_safety.c
	@echo '    printf("✅ Data stored safely: %s\\n", patient_buffer);' >> src/memory_safety.c
	@echo '    ' >> src/memory_safety.c
	@echo '    // Secure cleanup (zero memory before free)' >> src/memory_safety.c
	@echo '    memset(patient_buffer, 0, 256);' >> src/memory_safety.c
	@echo '    free(patient_buffer);' >> src/memory_safety.c
	@echo '    printf("🗑️  Memory securely cleaned\\n");' >> src/memory_safety.c
	@echo '    ' >> src/memory_safety.c
	@echo '    return 0;' >> src/memory_safety.c
	@echo '}' >> src/memory_safety.c
	@$(WASI_SDK)/clang src/memory_safety.c -o build/memory_safety.wasm
	@echo "✅ Compiled: build/memory_safety.wasm"
	@echo "🔬 Testing memory safety..."
	@wasmtime build/memory_safety.wasm
	@echo ""
	@echo "📋 Lab 1.3 Complete!"
	@echo "🎓 Module 01 Complete! Next: ../02-elixir-otp/"

clean:
	@rm -rf build src labs
	@echo "🧹 Cleaned up build artifacts"

# Help
help:
	@echo "🏥 WebAssembly Healthcare Labs"
	@echo ""
	@echo "Commands:"
	@echo "  make start     - Begin learning journey"
	@echo "  make lab-1.1   - Hello Medical Component"
	@echo "  make lab-1.2   - Patient Data File I/O"
	@echo "  make lab-1.3   - Memory Safety Demo"
	@echo "  make clean     - Remove build artifacts"
	@echo ""
	@echo "📚 Based on: ../../guia_wasm_iniciante.md"