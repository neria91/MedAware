import os
from flask import Flask, request, make_response
import mysql.connector
import shutil
import json

app = Flask(__name__)


@app.route('/handle_db_req', methods=['POST'])
def handle_db_req():
    req_data = request.get_json()
    is_db = req_data.get('is_db', False)
    file_name = req_data.get('file_name')
    if not search_similar_file(file_name):
        return f"no such file named {file_name} in the directory\n"

    file_location = f"/tmp/PreArchive/{file_name}"
    file_content = read_file(file_location)
    if is_db:
        move_to_archive(file_location, file_name)
        status = write_to_db(file_name, file_content)
        return f'{file_name}\n{status}\n'
    return f'the content of {file_name} is:\n{file_content}\n'


def search_similar_file(file_name):
    directory = '/tmp/PreArchive'
    for file in os.listdir(directory):
        if file_name == file:
            return True
    return False


def read_file(file_location):
    if not os.access(file_location, os.R_OK):
        response = make_response("No read permission on the file\n")
        response.status_code = 403
        return response

    try:
        with open(file_location, 'r') as file:
            file_content = file.read()
    except IOError:
        response = make_response("Error reading the file\n")
        response.status_code = 500
        return response

    return file_content


def move_to_archive(file_location , file_name):
    dest = f'/tmp/Archive/{file_name}'
    directory_path = os.path.dirname(dest)
    if not os.path.isdir(directory_path):
        response = make_response("Destination directory doesn't exist\n")
        response.status_code = 404
        return response

    if not os.access(directory_path, os.W_OK | os.X_OK):
        response = make_response("No write permission on the destination directory\n")
        response.status_code = 403
        return response

    try:
        shutil.move(file_location, dest)
        return "Success: File moved"
    except Exception as e:
        response = make_response(f"Error moving the file: {str(e)}\n")
        response.status_code = 500
        return response


def write_to_db(file_name, file_content):
    connection = None
    cursor = None
    mysql_host = os.getenv("MYSQL_HOST")
    mysql_user = os.getenv("MYSQL_USER")
    mysql_password = os.getenv("MYSQL_PASSWORD")
    mysql_database = os.getenv("MYSQL_DATABASE")

    try:
        connection = mysql.connector.connect(
            host=mysql_host,
            user=mysql_user,
            password=mysql_password
        )

        cursor = connection.cursor()

        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {mysql_database}")
        cursor.execute(f"USE {mysql_database}")
        cursor.execute(f"CREATE TABLE IF NOT EXISTS files (file_name CHAR(30) UNIQUE, content TEXT)")
        cursor.execute(f"INSERT INTO files (file_name, content) VALUES (%s, %s)", (file_name, file_content))

        connection.commit()
    except mysql.connector.Error as error:
        if connection:
            connection.rollback()
        return f"Failed to execute SQL commands: {str(error)}"
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

    return "Successfully wrote to the database"


if __name__ == '__main__':
    app.run()
