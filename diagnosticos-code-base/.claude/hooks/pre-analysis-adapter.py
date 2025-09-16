#!/usr/bin/env python3

"""
Adaptive Pre-Analysis Hook for Universal Code Diagnostics
Detects stack and sets contextual variables for the analysis
"""

import os
import sys
import json
import subprocess
from pathlib import Path

def detect_primary_language(project_path):
    """Detect the primary programming language based on file counts."""

    language_extensions = {
        'JavaScript': ['.js', '.mjs'],
        'TypeScript': ['.ts', '.tsx'],
        'Python': ['.py'],
        'Elixir': ['.ex', '.exs'],
        'Ruby': ['.rb'],
        'Go': ['.go'],
        'Rust': ['.rs'],
        'Java': ['.java'],
        'PHP': ['.php'],
        'C++': ['.cpp', '.cc', '.cxx'],
        'C': ['.c'],
        'C#': ['.cs']
    }

    language_counts = {}

    # Walk through directory and count files
    for root, dirs, files in os.walk(project_path):
        # Skip common directories
        dirs[:] = [d for d in dirs if d not in ['node_modules', 'vendor', '.git', 'build', 'dist', 'target', '__pycache__']]

        for file in files:
            file_path = Path(file)
            ext = file_path.suffix.lower()

            for language, extensions in language_extensions.items():
                if ext in extensions:
                    language_counts[language] = language_counts.get(language, 0) + 1
                    break

    if not language_counts:
        return 'Unknown'

    # Return the language with most files
    return max(language_counts, key=language_counts.get)

def detect_framework(project_path, primary_language):
    """Detect framework based on config files and primary language."""

    framework_indicators = {
        # JavaScript/TypeScript frameworks
        'package.json': {
            'react': 'React',
            'vue': 'Vue.js',
            'angular': 'Angular',
            'express': 'Express.js',
            'next': 'Next.js',
            'nuxt': 'Nuxt.js',
            'svelte': 'Svelte',
            'gatsby': 'Gatsby'
        },

        # Python frameworks
        'requirements.txt': {
            'django': 'Django',
            'flask': 'Flask',
            'fastapi': 'FastAPI',
            'tornado': 'Tornado',
            'pyramid': 'Pyramid'
        },

        # Other config files
        'mix.exs': {
            'phoenix': 'Phoenix'
        },

        'Gemfile': {
            'rails': 'Ruby on Rails',
            'sinatra': 'Sinatra'
        },

        'go.mod': {
            'gin': 'Gin',
            'echo': 'Echo',
            'fiber': 'Fiber'
        },

        'Cargo.toml': {
            'axum': 'Axum',
            'actix-web': 'Actix-web',
            'warp': 'Warp'
        },

        'composer.json': {
            'laravel': 'Laravel',
            'symfony': 'Symfony'
        }
    }

    detected_frameworks = []

    for config_file, frameworks in framework_indicators.items():
        config_path = os.path.join(project_path, config_file)
        if os.path.exists(config_path):
            try:
                with open(config_path, 'r', encoding='utf-8') as f:
                    content = f.read().lower()
                    for framework_key, framework_name in frameworks.items():
                        if framework_key in content:
                            detected_frameworks.append(framework_name)
            except Exception:
                continue

    return detected_frameworks[0] if detected_frameworks else f"{primary_language} (No specific framework detected)"

def detect_project_type(project_path):
    """Detect project type based on directory structure and files."""

    # Check for common project indicators
    indicators = {
        'Web Application': ['public', 'static', 'assets', 'www'],
        'API/Backend': ['api', 'routes', 'controllers'],
        'Library/Package': ['lib', 'src/lib'],
        'CLI Application': ['bin', 'cmd', 'cli'],
        'Mobile App': ['android', 'ios', 'mobile'],
        'Desktop App': ['desktop', 'electron'],
        'Microservice': ['services', 'docker-compose.yml'],
        'Data Pipeline': ['pipeline', 'etl', 'data'],
        'Documentation': ['docs', 'documentation']
    }

    for project_type, dirs_files in indicators.items():
        for indicator in dirs_files:
            if os.path.exists(os.path.join(project_path, indicator)):
                return project_type

    return 'General Application'

def detect_architecture_pattern(project_path):
    """Detect architecture pattern based on directory structure."""

    patterns = {
        'MVC': ['controllers', 'models', 'views'],
        'Component-Based': ['components', 'hooks'],
        'Service Layer': ['services', 'repositories'],
        'Microservices': ['services', 'docker-compose.yml'],
        'Serverless': ['serverless.yml', 'sam-template.yaml'],
        'Modular Monolith': ['modules', 'packages'],
        'Clean Architecture': ['domain', 'infrastructure', 'application'],
        'Hexagonal': ['ports', 'adapters'],
        'Layered': ['presentation', 'business', 'data']
    }

    detected_patterns = []

    for pattern_name, indicators in patterns.items():
        if all(os.path.exists(os.path.join(project_path, indicator)) or
               any(os.path.exists(os.path.join(root, indicator))
                   for root, dirs, files in os.walk(project_path)
                   if indicator in dirs or indicator in files)
               for indicator in indicators):
            detected_patterns.append(pattern_name)

    return detected_patterns[0] if detected_patterns else 'Layered (Default)'

def get_project_metrics(project_path):
    """Get basic project metrics."""

    exclude_dirs = {'node_modules', 'vendor', '.git', 'build', 'dist', 'target', '__pycache__'}

    total_files = 0
    total_lines = 0
    code_files = 0

    for root, dirs, files in os.walk(project_path):
        dirs[:] = [d for d in dirs if d not in exclude_dirs]

        for file in files:
            if not file.startswith('.'):
                total_files += 1
                file_path = os.path.join(root, file)

                # Count lines in code files
                code_extensions = {'.py', '.js', '.ts', '.ex', '.exs', '.rb', '.go', '.rs', '.java', '.php', '.cpp', '.c', '.cs'}
                if any(file.endswith(ext) for ext in code_extensions):
                    code_files += 1
                    try:
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                            total_lines += sum(1 for line in f if line.strip())
                    except Exception:
                        pass

    return {
        'total_files': total_files,
        'code_files': code_files,
        'total_lines': total_lines
    }

def count_dependencies(project_path):
    """Count dependencies from various package managers."""

    dep_files = {
        'package.json': lambda f: len([line for line in f.read().split('\n') if '"' in line and ':' in line]),
        'requirements.txt': lambda f: len([line for line in f.read().split('\n') if line.strip() and not line.startswith('#')]),
        'mix.exs': lambda f: f.read().count('def deps'),
        'Gemfile': lambda f: f.read().count('gem '),
        'go.mod': lambda f: f.read().count('require'),
        'Cargo.toml': lambda f: len([line for line in f.read().split('\n') if '=' in line and '[' not in line]),
        'composer.json': lambda f: len([line for line in f.read().split('\n') if '"' in line and ':' in line])
    }

    total_deps = 0

    for dep_file, counter in dep_files.items():
        dep_path = os.path.join(project_path, dep_file)
        if os.path.exists(dep_path):
            try:
                with open(dep_path, 'r', encoding='utf-8') as f:
                    total_deps += counter(f)
            except Exception:
                continue

    return total_deps

def main():
    """Main hook function."""

    # Get project path from arguments or current directory
    project_path = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()

    print(f"🔍 Adaptive Pre-Analysis Hook")
    print(f"📁 Project Path: {project_path}")
    print(f"=====================================")

    # Perform detection
    primary_language = detect_primary_language(project_path)
    framework = detect_framework(project_path, primary_language)
    project_type = detect_project_type(project_path)
    architecture = detect_architecture_pattern(project_path)
    metrics = get_project_metrics(project_path)
    dependencies_count = count_dependencies(project_path)

    # Create context object
    context = {
        'PROJECT_PATH': project_path,
        'PRIMARY_LANGUAGE': primary_language,
        'FRAMEWORK': framework,
        'PROJECT_TYPE': project_type,
        'ARCHITECTURE_PATTERN': architecture,
        'DETECTED_STACK': f"{primary_language} + {framework}",
        'LOC': metrics['total_lines'],
        'DEPENDENCIES_COUNT': dependencies_count,
        'CODE_FILES': metrics['code_files'],
        'TOTAL_FILES': metrics['total_files']
    }

    # Output context for Claude to use
    print("📋 DETECTED PROJECT CONTEXT:")
    print("----------------------------")
    for key, value in context.items():
        print(f"  {key}: {value}")

    print("\n✅ Context detection complete!")
    print("📝 Use these variables to customize your diagnostic approach.")

    # Suggest appropriate diagnostic focus based on detected stack
    print(f"\n💡 RECOMMENDED DIAGNOSTIC FOCUS FOR {primary_language}:")
    print("------------------------------------------------")

    focus_recommendations = {
        'JavaScript': [
            "npm audit for security vulnerabilities",
            "Check for unused dependencies",
            "Analyze bundle size and performance",
            "Review async/await vs Promise patterns"
        ],
        'TypeScript': [
            "Type safety analysis",
            "Check for any types usage",
            "Interface vs type alias consistency",
            "Strict mode configuration review"
        ],
        'Python': [
            "Check for security issues with bandit",
            "PEP 8 compliance review",
            "Virtual environment best practices",
            "Type hints coverage analysis"
        ],
        'Elixir': [
            "OTP principles compliance",
            "GenServer pattern usage review",
            "Supervision tree analysis",
            "Performance bottlenecks in processes"
        ],
        'Go': [
            "Race condition detection",
            "Goroutine leak analysis",
            "Error handling patterns review",
            "Memory allocation optimization"
        ],
        'Rust': [
            "Unsafe block audit",
            "Ownership pattern analysis",
            "Cargo security audit",
            "Performance benchmarking"
        ]
    }

    recommendations = focus_recommendations.get(primary_language, ["General code quality review"])

    for i, rec in enumerate(recommendations, 1):
        print(f"  {i}. {rec}")

    return 0

if __name__ == "__main__":
    sys.exit(main())