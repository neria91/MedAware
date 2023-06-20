The project aims to create a system that handles HTTP POST requests and performs different actions based on the request parameters. 
If the request parameter 'is_db' is set to true, the system will write the data to a database and return the file_name. 
If the parameter 'is_db' is set to false, the system will return the content of the requested file.



After you pull the project use  "docker compose up -d" in the project's directory (of course you should have docker and docker compose)



You can change the local variables in .env , it should be in '.gitignore' and '.dockerignore' but it is not for easy test in this scenario.



Run  test.sh to see few different cases of how the system functioning.



To make your own requests, you can use the built-in curl command. Modify the request parameters according to your requirements. 
Here's an example:

curl -X POST "http://127.0.0.1:7410/handle_db_req" -H 'Content-Type: application/json' -d '{ "is_db": false, "file_name": "1.txt" }'
