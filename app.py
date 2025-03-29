#=========================================================================================
# INFO BLOCK
#
#=========================================================================================

# Imports
from flask import Flask, render_template, request, jsonify
import mysql.connector
import traceback
import html
import os

app = Flask(__name__)

# Update these credentials to match your MySQL setup
db_config = {
    'host': os.getenv('MYSQLHOST'),
    'user': os.getenv('MYSQLUSER'),
    'password': os.getenv('MYSQL_ROOT_PASSWORD'),
    'database': os.getenv('MYSQLDATABASE'),
    'port': int(os.getenv('MYSQLPORT', 3306))
}

def sanitize_input(value):
    if isinstance(value, str):
        return html.escape(value.strip())
    return value

def call_procedure(proc_name, args=()):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.callproc(proc_name, args)
        conn.commit()
        results = []
        for result in cursor.stored_results():
            results.extend(result.fetchall())
        return {"success": True, "data": results or "Procedure executed successfully."}
    except Exception as e:
        return {"success": False, "error": str(e), "trace": traceback.format_exc()}
    finally:
        cursor.close()
        conn.close()

def call_function(query, args=()):
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute(query, args)
        result = cursor.fetchone()
        return {"success": True, "data": result[0] if result else "No result"}
    except Exception as e:
        return {"success": False, "error": str(e), "trace": traceback.format_exc()}
    finally:
        cursor.close()
        conn.close()

@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

@app.route('/procedure', methods=['POST'])
def procedure():
    action = request.form.get("action")

    args_map = {
        "AddPlayToProduction": [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['PlayID']))
        ],
        "UndoPlayFromProduction": [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['PlayID']))
        ],
        "AddProductionExpense": [
            float(sanitize_input(request.form['Amount'])),
            sanitize_input(request.form['Date']),
            int(sanitize_input(request.form['ProductionID'])),
            sanitize_input(request.form['Description'])
        ],
        "UndoProductionExpense": [
            int(sanitize_input(request.form['TransactionID']))
        ],
        "AddDuesInstallment": [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['Year'])),
            float(sanitize_input(request.form['Amount']))
        ],
        "UndoDuesInstallment": [
            int(sanitize_input(request.form['PaymentID']))
        ],
        "PurchaseTicket": [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['SeatID'])),
            int(sanitize_input(request.form['PatronID'])) if request.form['PatronID'] else None,
            float(sanitize_input(request.form['Price']))
        ],
        "UndoTicketPurchase": [
            int(sanitize_input(request.form['TicketID']))
        ],
        "GetProductionFinancialSummary": [
            int(sanitize_input(request.form['ProductionID'])) if request.form['ProductionID'] else None,
            sanitize_input(request.form['StartDate']) if request.form['StartDate'] else None,
            sanitize_input(request.form['EndDate']) if request.form['EndDate'] else None
        ]
    }

    if action not in args_map:
        return jsonify({"success": False, "error": f"Unknown procedure: {action}"})

    return jsonify(call_procedure(action, args_map[action]))

@app.route('/function', methods=['POST'])
def function():
    if request.form.get("action") == "GetTotalPaidForDues":
        dues_id = int(sanitize_input(request.form['DuesID']))
        return jsonify(call_function("SELECT GetTotalPaidForDues(%s)", (dues_id,)))
    return jsonify({"success": False, "error": "Unknown function action"})

if __name__ == '__main__':
    app.run(debug=True)

# END OF DOC