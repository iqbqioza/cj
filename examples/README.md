# Examples

This directory contains example CSV files demonstrating various features and use cases of the cj CSV to JSON converter.

## Sample Files

### basic.csv
A simple CSV file with basic data types.

```csv
no,name,title,memo,datetime
1,Joe,Hello World,,2025-07-26 10:24:00
2,Jack,Lorem Ipsum,,2025-10-24 10:24:00
```

**Usage:**
```bash
# Compact JSON output
./cj examples/basic.csv

# Formatted JSON output
./cj --styled examples/basic.csv
```

### multiline.csv
Demonstrates multiline fields within quoted strings.

**Usage:**
```bash
./cj --styled examples/multiline.csv
```

**Features:**
- Fields spanning multiple lines
- Proper quote escaping
- Mixed content types

### numeric.csv
Shows automatic numeric type detection.

**Usage:**
```bash
./cj examples/numeric.csv
```

**Features:**
- Integer values (output as numbers)
- Float values (output as numbers)  
- Text values (output as strings)
- Mixed alphanumeric (output as strings)

## Creating Your Own Examples

### Simple Data
```csv
id,name,age,active
1,Alice,25,true
2,Bob,30,false
3,Charlie,35,true
```

### Complex Data with Special Characters
```csv
id,description,notes
1,"Product with ""quotes""","Multi-line
notes here"
2,"Product, with commas","Single line"
3,"Product with \t tabs","Another note"
```

### Numeric Data
```csv
product_id,price,quantity,discount
1001,29.99,5,0.1
1002,15.50,10,0.0
1003,99.99,1,0.25
```

## Expected Output Examples

### Basic CSV → JSON
**Input (`basic.csv`):**
```csv
no,name,title,memo,datetime
1,Joe,Hello World,,2025-07-26 10:24:00
2,Jack,Lorem Ipsum,,2025-10-24 10:24:00
```

**Compact Output:**
```json
[{"no": 1,"name": "Joe","title": "Hello World","memo": "","datetime": "2025-07-26 10:24:00"},{"no": 2,"name": "Jack","title": "Lorem Ipsum","memo": "","datetime": "2025-10-24 10:24:00"}]
```

**Styled Output:**
```json
[
  {
    "no": 1,
    "name": "Joe", 
    "title": "Hello World",
    "memo": "",
    "datetime": "2025-07-26 10:24:00"
  },
  {
    "no": 2,
    "name": "Jack",
    "title": "Lorem Ipsum", 
    "memo": "",
    "datetime": "2025-10-24 10:24:00"
  }
]
```

## Testing Examples

You can test all examples at once:

```bash
# Test all examples
for file in examples/*.csv; do
    echo "Testing: $file"
    ./cj "$file" > /dev/null && echo "✓ PASS" || echo "✗ FAIL"
done

# Test with styled output
for file in examples/*.csv; do
    echo "Testing styled: $file"  
    ./cj --styled "$file" > /dev/null && echo "✓ PASS" || echo "✗ FAIL"
done
```

## Use Cases

### 1. Data Migration
Convert CSV exports from databases or spreadsheets to JSON for API consumption.

### 2. Configuration Files
Transform CSV configuration data into JSON format for web applications.

### 3. Data Processing
Prepare CSV data for processing by JSON-based tools and libraries.

### 4. API Development
Convert CSV test data into JSON format for API testing and development.

### 5. Web Development
Transform CSV datasets into JSON for client-side JavaScript applications.

## Tips

1. **Test with your data**: Copy your CSV files here to test compatibility
2. **Check edge cases**: Try files with special characters, empty fields, and multiline content
3. **Validate output**: Use `jq` or similar tools to validate the JSON output
4. **Performance testing**: Test with larger files to check memory usage

```bash
# Validate JSON output
./cj examples/basic.csv | jq . > /dev/null && echo "Valid JSON"

# Pretty print with jq
./cj examples/basic.csv | jq .

# Extract specific fields
./cj examples/basic.csv | jq '.[].name'
```