#!/bin/bash

# PlantUML Diagram Validation Script
# This script checks the syntax of all PlantUML diagrams

echo "🔍 Validating PlantUML diagrams..."

PLANTUML_DIR="/root/devops-blog-project/plantuml"
cd "$PLANTUML_DIR"

# Check if any .puml files exist
if ! ls *.puml 1> /dev/null 2>&1; then
    echo "❌ No .puml files found in $PLANTUML_DIR"
    exit 1
fi

# Count total diagrams
TOTAL_DIAGRAMS=$(ls *.puml | wc -l)
echo "📊 Found $TOTAL_DIAGRAMS PlantUML diagrams to validate"

# Basic syntax validation
VALID_COUNT=0
ERROR_COUNT=0

echo ""
echo "Checking basic syntax..."

for diagram in *.puml; do
    echo -n "  Checking $diagram... "
    
    # Check for basic PlantUML syntax requirements
    if grep -q "@startuml" "$diagram" && grep -q "@enduml" "$diagram"; then
        # Check for common syntax issues
        if grep -q "^[[:space:]]*@startuml" "$diagram" && 
           grep -q "^[[:space:]]*@enduml" "$diagram" &&
           ! grep -q "[[:space:]]$" "$diagram"; then
            echo "✅ Valid"
            ((VALID_COUNT++))
        else
            echo "⚠️  Warning: Possible formatting issues"
            ((VALID_COUNT++))
        fi
    else
        echo "❌ Invalid: Missing @startuml or @enduml"
        ((ERROR_COUNT++))
    fi
done

echo ""
echo "📈 Validation Summary:"
echo "  ✅ Valid diagrams: $VALID_COUNT"
echo "  ❌ Invalid diagrams: $ERROR_COUNT"
echo "  📊 Total diagrams: $TOTAL_DIAGRAMS"

if [ $ERROR_COUNT -eq 0 ]; then
    echo ""
    echo "🎉 All diagrams passed basic validation!"
    echo ""
    echo "💡 To generate diagrams:"
    echo "  Online: Copy content to https://www.plantuml.com/plantuml/uml/"
    echo "  Local:  java -jar plantuml.jar *.puml"
    echo "  VSCode: Install PlantUML extension and preview"
    exit 0
else
    echo ""
    echo "⚠️  Some diagrams have issues. Please review and fix."
    exit 1
fi
