from flask import Flask , jsonify , request
from flask_cors import CORS
import numpy as np
import cv2
from face_new import face_recognition
import mysql.connector
import os

app = Flask(__name__)
CORS(app)

obj = face_recognition()

station_idx = {
    'S1': 0,  # Sealdah
    'S2': 1,  # Phoolbagan
    'S3': 2,  # Salt Lake Stadium
    'S4': 3,  # Bengal Chemical
    'S5': 4,  # City Center
    'S6': 5,  # Central Park
    'S7': 6,  # Karunamoyee
    'S8': 7   # Salt Lake Sector V
}

stn_path_cost = [
    # 0   1   2   3   4   5   6   7
    [ 0,  5,  8, 11, 14, 17, 20, 20],  # 0  Sealdah
    [ 5,  0,  5,  8, 11, 14, 17, 20],  # 1  Phoolbagan
    [ 8,  5,  0,  5,  8, 11, 14, 17],  # 2  Salt Lake Stadium
    [11,  8,  5,  0,  5,  8, 11, 14],  # 3  Bengal Chemical
    [14, 11,  8,  5,  0,  5,  8, 11],  # 4  City Center
    [17, 14, 11,  8,  5,  0,  5,  8],  # 5  Central Park
    [20, 17, 14, 11,  8,  5,  0,  5],  # 6  Karunamoyee
    [20, 20, 17, 14, 11,  8,  5,  0]   # 7  Salt Lake Sector V
]


DATASET_PATH = r'C:\Users\Anjan Das\Desktop\hack4Bengal_4.0\dataset'

def get_db_connection():
     #Database connection setup
    db = mysql.connector.connect(
        host="localhost",
        port=3306,  
        user="root",  
        password="anjan@8427",
        database="world"
    )
    print(" Database connected successfully!")

    # Optional: show tables in the database on startup
    cursor = db.cursor()
    cursor.execute("SHOW TABLES")
    tables = cursor.fetchall()
    print(" Tables in DB:", [t[0] for t in tables])

    return db

#User section

#bio update
@app.route('/biometric' , methods=['GET' , 'POST'])
def biometric():
    file = request.files['image']
    name = request.form.get('name')
    user_id =request.form.get('user_id')
    npimg = np.frombuffer(file.read(), np.uint8)
    frame = cv2.imdecode(npimg, cv2.IMREAD_COLOR)

    if frame is None:
        return {"success":False , "message":"Image corrupted"} , 500

    user_folder = os.path.join(DATASET_PATH, user_id)

    if os.path.isdir(user_folder):
        # Folder already exists replace: delete old files
        for old_file in os.listdir(user_folder):
            try:
                os.remove(os.path.join(user_folder, old_file))
            except OSError:
                pass
    else:
        # Fresh user ➜ create folder
        os.makedirs(user_folder, exist_ok=True)
    
    filename = f"{user_id}.jpg"
    user_folder = os.path.join(user_folder,filename)
    if not cv2.imwrite(user_folder, frame):
        return {"success":False , "message":"Image not saved!"} , 500
    #adde the user embeddings
    obj.scan_dataset()

    return {"success":True , "message":"Image uploaded successfully"} , 200


@app.route('/wallet_check' , methods=['GET' , 'POST'])
def wallet_check():
    print("Hello")
    data = request.get_json()
    
    user_id = data.get('user_id')
    print("Given id",user_id)

    query = 'SELECT wallet_balance from user_table where user_id = %s';
 
    try:
        
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query , (user_id,))
        data = cursor.fetchone()
        print(data)

        amount =data['wallet_balance']
        print(amount)
        conn.close()
        
        return {"success":True , 'amount': amount} , 200
    except Exception as e:
        print({"error": str(e)})
    


@app.route('/wallet_update' , methods=['GET' , 'POST'])
def wallet_update():
    data = request.get_json()
    name = data.get('user_name')
    user_id = data.get('user_id')
    balance = data.get('amount')

    print("Balance given :",balance)

    query = 'SELECT wallet_balance from user_table where user_id = %s;'
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query , (user_id,))
        data = cursor.fetchone()
        print(data)

        final_amount = balance + data['wallet_balance']
        print(final_amount)
        query1 = 'update user_table set wallet_balance = %s where user_id = %s;'
        cursor.execute(query1 , (final_amount,user_id,))
        cursor.execute(query , (user_id,))
        data = cursor.fetchone()
        print(data)
        conn.commit()
        conn.close()
        
        return {"success":True , 'amount': final_amount} , 200
    except Exception as e:
        print({"error": str(e)})
    
    

#login_check




@app.route('/destination', methods=['GET','POST'])
def station_scan():
    # ── form/multipart parsing ──────────────────────────────
    file         = request.files.get('image')
    station_id   = request.form.get('station_id')
    station_type = request.form.get('station_type', '').lower()  # 'source' or 'destination'
    print(station_type)

    if not file or not station_id or station_type not in ('source', 'destination'):
        return jsonify({"success": False, "error": "Bad request"}), 400

    # ── image decode ────────────────────────────────────────
    frame = cv2.imdecode(np.frombuffer(file.read(), np.uint8), cv2.IMREAD_COLOR)
    if frame is None:
        return jsonify({"success": False, "error": "Image corrupted"}), 400

    # ── face recognition ────────────────────────────────────
    obj.load_embeddings()
    obj.scan_dataset()
    match = obj.recognize_faces(frame)
    if not match:
        return jsonify({"success": False, "error": "Face not recognised"}), 404
    user_id = match[0]
    user_id = user_id['name']
    print("user id",user_id)

    # ── DB work ─────────────────────────────────────────────
    try:
        conn   = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # fetch user name once
        cursor.execute('SELECT user_name FROM user_table WHERE user_id = %s', (user_id,))
        row = cursor.fetchone()
        print(row)
        if not row:
            return jsonify({"success": False, "error": "Unknown user"}), 404
        user_name = row['user_name']

        if station_type == 'source':                      # ENTRY
            cursor.execute("""
                INSERT INTO user_log (user_id, user_name, entry_stn_id)
                VALUES (%s, %s, %s)
            """, (user_id, user_name, station_id))

        else:   
            #entry_std
            cursor.execute("""
                SELECT entry_stn_id from user_log where user_id = %s and exit_stn_id is NULL
            """, (user_id,))
            entry_stn_id = cursor.fetchone()
            entry_stn_id = entry_stn_id['entry_stn_id']
            print("Entry stn id",entry_stn_id)

            query = 'SELECT wallet_balance from user_table where user_id = %s';
            conn = get_db_connection()
            cursor = conn.cursor(dictionary=True)
            cursor.execute(query , (user_id,))
            data = cursor.fetchone()
            print(data)
            amount =data['wallet_balance']
            print(amount)

            # Now these are plain strings, safe for dict lookup
            i = station_idx[entry_stn_id]
            j = station_idx[station_id]
            path_cost = stn_path_cost[i][j]
            print(path_cost)
            amount -= path_cost
            print(amount) 
        
            # EXIT
            cursor.execute("""
                UPDATE user_log
                   SET exit_stn_id = %s,
                    exit_time = CURRENT_TIMESTAMP  
                 WHERE user_id     = %s
                   AND exit_stn_id IS NULL
              ORDER BY entry_time DESC
                 LIMIT 1
            """, (station_id, user_id,))

            if cursor.rowcount == 0:
                return jsonify({"success": False, "error": "No open trip to close"}), 404
            
            #deduct fare directly in SQL (atomic)
            cursor.execute("""
                UPDATE user_table
                SET wallet_balance =  %s
                WHERE user_id = %s
            """, (amount, user_id))

        conn.commit()
        return jsonify({"success": True}), 200

    except Exception as exc:
        print("DB error:", exc)
        conn.rollback()
        return jsonify({"success": False, "error": "Server failure"}), 500

    finally:
        cursor.close()
        conn.close()



        
#admin panel section

# Utility to convert datetime objects to strings
def serialize_logs(logs, is_entry=True):
    result = []
    for row in logs:
        result.append({
            "user_id": row['user_id'],
            "user_name": row['user_name'],
            "entry_time" if is_entry else "exit_time":
                row['entry_time' if is_entry else 'exit_time'].strftime('%Y-%m-%d %H:%M:%S') if row[('entry_time' if is_entry else 'exit_time')] else None
        })
    return result

#  1) Get station ID from station name
# -----------------------------------------------------------
@app.route('/station_id', methods=['GET', 'POST'])
def station_id():
    print("Hello /station_id")
    data = request.get_json(force=True)
    
    station_name = data.get('station_name')
    print("Given station_name:", station_name)
    
    query = 'SELECT stn_id FROM stations WHERE stn_name = %s LIMIT 1;'
    
    try:
        conn   = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, (station_name,))
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return {"success": True, "station_id": row['stn_id']}, 200
        else:
            return {"success": False, "error": "Station not found"}, 404

    except Exception as e:
        print({"error": str(e)})
        return {"success": False, "error": "server failure"}, 500


# -----------------------------------------------------------
#  2) Get latest entry/exit details for a station ID
# -----------------------------------------------------------
@app.route('/station_log', methods=['GET', 'POST'])
def station_log():
    print("Hello /station_log")
    data = request.get_json(force=True)
    
    station_id = data.get('station_id')
    print("Given station_id:", station_id)
    
    q_name    = 'SELECT stn_name FROM stations WHERE stn_id = %s LIMIT 1;'
    q_entries = '''
        SELECT user_id, user_name, entry_time
          FROM user_log
         WHERE entry_stn_id = %s AND exit_stn_id is NULL
      ORDER BY entry_time DESC
         LIMIT 5;
    '''
    q_exits   = '''
        SELECT user_id, user_name, exit_time
          FROM user_log
         WHERE exit_stn_id = %s
      ORDER BY exit_time DESC
         LIMIT 5;
    '''
    
    try:
        conn   = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # station name
        cursor.execute(q_name, (station_id,))
        row = cursor.fetchone()
        if not row:
            conn.close()
            return {"success": False, "error": "Unknown station"}, 404
        station_name = row['stn_name']
        print("Station:", station_name)
        
        # entries
        cursor.execute(q_entries, (station_id,))
        entries = cursor.fetchall()
        print("Entries:", entries)
        
        # exits
        cursor.execute(q_exits, (station_id,))
        exits = cursor.fetchall()
        print("Exits:", exits)
        
        conn.close()
        
        return {
            "success": True,
            "station_id": station_id,
            "station_name": station_name,
            "entries": serialize_logs(entries, is_entry=True),
            "exits": serialize_logs(exits, is_entry=False)
        }, 200
            
    except Exception as e:
        print({"error": str(e)})
        return {"success": False, "error": "server failure"}, 500


#stations nodes 


# bio check

@app.route('/get_user_details', methods=['POST'])
def get_user_details():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    print(email , password)
    
    query = "SELECT * FROM user_table WHERE user_email = %s and user_password = %s;"
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query , (email,password,))
        data = cursor.fetchone()
        print(data)
        conn.close()
        return {"success":True , 'data': data} , 200
    except Exception as e:
        print({"error": str(e)})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)

