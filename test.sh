#!/bin/bash

echo "Stage 1: Creating files in PreArchive folder"
echo "Creating 1.txt..."
echo "111111111" > PreArchive/1.txt
echo "Creating 2.txt..."
echo "222222" > PreArchive/2.txt
echo "Creating 3.txt..."
echo "333333" > PreArchive/3.txt
echo "Creating 4.txt..."
echo "444444" > PreArchive/4.txt

echo ""
echo "Stage 2: Calling non-existing files"
echo "Calling for file 6.txt..."
curl -X POST "http://127.0.0.1:7410/handle_db_req" -H 'Content-Type: application/json' -d '{ "is_db": true, "file_name": "6.txt" }'

echo ""
echo "Stage 3: Trying false and true"
echo "Calling for file 1.txt (is_db=false)..."
curl -X POST "http://127.0.0.1:7410/handle_db_req" -H 'Content-Type: application/json' -d '{ "is_db": false, "file_name": "1.txt" }'
echo "Calling for file 1.txt (is_db=true)..."
curl -X POST "http://127.0.0.1:7410/handle_db_req" -H 'Content-Type: application/json' -d '{ "is_db": true, "file_name": "1.txt" }'
echo "Calling for file 2.txt (is_db=true)..."
curl -X POST "http://127.0.0.1:7410/handle_db_req" -H 'Content-Type: application/json' -d '{ "is_db": true, "file_name": "2.txt" }'
echo "Calling for file 3.txt (is_db=false)..."
curl -X POST "http://127.0.0.1:7410/handle_db_req" -H 'Content-Type: application/json' -d '{ "is_db": false, "file_name": "3.txt" }'

echo ""
echo "Stage 4: Checking the unique key"
echo "Creating a new 1.txt with content 'FAKE' since it's a duplicate"
echo "FAKE" > PreArchive/1.txt
echo "Calling for file 1.txt (true)..."
curl -X POST "http://127.0.0.1:7410/handle_db_req" -H 'Content-Type: application/json' -d '{ "is_db": true, "file_name": "1.txt" }'

echo ""
echo "Stage 5: Checking nginx filtering"
echo "Sending a request to a wrong port..."
curl -X POST "http://127.0.0.1:8520/handle_db_req" -H 'Content-Type: application/json' -d '{ "is_db": false, "file_name": "4.txt" }'
echo "Sending a request with GET method instead of POST..."
curl -X GET "http://127.0.0.1:7410/handle_db_req" -H 'Content-Type: application/json' -d '{ "is_db": false, "file_name": "4.txt" }'

echo ""
echo "Listing files in Archive folder - we expect to have 1.txt and 2.txt"
echo "Checking with the 'ls' command:"
ls Archive/
