# DSM:TESTING:test_environment HEALTHCARE:test_suite_initialization
ExUnit.start()

# Setup test database
Ecto.Adapters.SQL.Sandbox.mode(HealthcareCMS.Repo, :manual)