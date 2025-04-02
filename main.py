#=========================================================================================
# INFO BLOCK
#
#=========================================================================================

# Imports
from flask import Flask, render_template, request, jsonify, redirect, url_for, session
import mysql.connector
from mysql.connector import Error as MySQLError
import traceback
import html
import os
from import_csv_to_mysql import import_csv_data
from datetime import timedelta

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
            fetched = result.fetchall()
            print(f"Fetched result from {proc_name}: {fetched}")
            results.extend(result.fetchall())
        return {"success": True, "data": results or "Procedure executed successfully."}
    except MySQLError as e:
        print("MySQL Error:", str(e))
        return {"success": False, "error": str(e)}
    except Exception as e:
        print("Exception during call_procedure:", str(e))
        print(traceback.format_exc())
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
    except MySQLError as e:
        print("MySQL Error:", str(e))
        return {"success": False, "error": str(e)}
    except Exception as e:
        print("Exception during call_function:", str(e))
        print(traceback.format_exc())
        return {"success": False, "error": str(e), "trace": traceback.format_exc()}
    finally:
        cursor.close()
        conn.close()

@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

@app.route('/procedure', methods=['POST'])
def procedure():
    print("Incoming form data:", request.form)
    action = request.form.get("action")
    print("Action received:", action)

    args_map = {
        "CreatePlay": lambda: [
            sanitize_input(request.form['Title']),
            sanitize_input(request.form['Author']),
            sanitize_input(request.form['Genre']),
            int(sanitize_input(request.form['NumberOfActs'])),
            float(sanitize_input(request.form['Cost']))
        ],
        "UpdatePlay": lambda: [
            int(sanitize_input(request.form['PlayID'])),
            sanitize_input(request.form['Title']),
            sanitize_input(request.form['Author']),
            sanitize_input(request.form['Genre']),
            int(sanitize_input(request.form['NumberOfActs'])),
            float(sanitize_input(request.form['Cost']))
        ],
        "DeletePlay": lambda: [
            int(sanitize_input(request.form['PlayID']))
        ],
        "CreateMember": lambda: [
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Email']),
            sanitize_input(request.form['Phone']),
            sanitize_input(request.form['Address']),
            sanitize_input(request.form['Role'])
        ],
        "UpdateMember": lambda: [
            int(sanitize_input(request.form['MemberID'])),
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Email']),
            sanitize_input(request.form['Phone']),
            sanitize_input(request.form['Address']),
            sanitize_input(request.form['Role'])
        ],
        "DeleteMember": lambda: [
            int(sanitize_input(request.form['MemberID']))
        ],
        "AssignMemberToProduction": lambda: [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['ProductionID'])),
            sanitize_input(request.form['Role'])
        ],
        "RemoveMemberFromProduction": lambda: [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['ProductionID']))
        ],
        "CreateProduction": lambda: [
            sanitize_input(request.form['ProductionDate'])
        ],
        "UpdateProduction": lambda: [
            int(sanitize_input(request.form['ProductionID'])),
            sanitize_input(request.form['ProductionDate'])
        ],
        "DeleteProduction": lambda: [
            int(sanitize_input(request.form['ProductionID']))
        ],
        "LinkSponsorToProduction": lambda: [
            int(sanitize_input(request.form['SponsorID'])),
            int(sanitize_input(request.form['ProductionID'])),
            float(sanitize_input(request.form['Amount']))
        ],
        "UnlinkSponsorFromProduction": lambda: [
            int(sanitize_input(request.form['SponsorID'])),
            int(sanitize_input(request.form['ProductionID']))
        ],
        "CreateTicket": lambda: [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['SeatID'])),
            float(sanitize_input(request.form['Price'])),
            sanitize_input(request.form['ReservationDeadline']) if request.form['ReservationDeadline'] else None
        ],
        "ReleaseTicket": lambda: [
            int(sanitize_input(request.form['TicketID']))
        ],
        "UpdateTicketStatus": lambda: [
            int(sanitize_input(request.form['TicketID'])),
            sanitize_input(request.form['Status'])
        ],
        "UpdateTicketPrice": lambda: [
            int(sanitize_input(request.form['TicketID'])),
            float(sanitize_input(request.form['NewPrice']))
        ],
        "CancelReservation": lambda: [
            int(sanitize_input(request.form['TicketID']))
        ],
        "CreateSponsor": lambda: [
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Type'])
        ],
        "UpdateSponsor": lambda: [
            int(sanitize_input(request.form['SponsorID'])),
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Type'])
        ],
        "DeleteSponsor": lambda: [
            int(sanitize_input(request.form['SponsorID']))
        ],
        "CreatePatron": lambda: [
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Email']),
            sanitize_input(request.form['Address'])
        ],
        "UpdatePatron": lambda: [
            int(sanitize_input(request.form['PatronID'])),
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Email']),
            sanitize_input(request.form['Address'])
        ],
        "DeletePatron": lambda: [
            int(sanitize_input(request.form['PatronID']))
        ],
        "CreateMeeting": lambda: [
            sanitize_input(request.form['Type']),
            sanitize_input(request.form['Date'])
        ],
        "UpdateMeeting": lambda: [
            int(sanitize_input(request.form['MeetingID'])),
            sanitize_input(request.form['Type']),
            sanitize_input(request.form['Date'])
        ],
        "DeleteMeeting": lambda: [
            int(sanitize_input(request.form['MeetingID']))
        ],
        "AssignMemberToMeeting": lambda: [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['MeetingID']))
        ],
        "RemoveMemberFromMeeting": lambda: [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['MeetingID']))
        ],
        "CreateDuesRecord": lambda: [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['Year'])),
            float(sanitize_input(request.form['TotalAmount']))
        ],
        "DeleteDuesRecord": lambda: [
            int(sanitize_input(request.form['DuesID']))
        ],
        "CheckSeatAvailability": lambda: [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['SeatID']))
        ],
        "ReserveTicket": lambda: [
            int(sanitize_input(request.form['TicketID'])),
            int(sanitize_input(request.form['PatronID'])),
            sanitize_input(request.form['Deadline']) if request.form['Deadline'] else None
        ],
        "CreateSeat": lambda: [
            sanitize_input(request.form['SeatRow']),
            int(sanitize_input(request.form['Number']))
        ],
        "UpdateSeat": lambda: [
            int(sanitize_input(request.form['SeatID'])),
            sanitize_input(request.form['SeatRow']),
            int(sanitize_input(request.form['Number']))
        ],
        "DeleteSeat": lambda: [
            int(sanitize_input(request.form['SeatID']))
        ],
        "AddPlayToProduction": lambda: [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['PlayID']))
        ],
        "UndoPlayFromProduction": lambda: [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['PlayID']))
        ],
        "AddProductionExpense": lambda: [
            float(sanitize_input(request.form['Amount'])),
            sanitize_input(request.form['Date']),
            int(sanitize_input(request.form['ProductionID'])),
            sanitize_input(request.form['Description'])
        ],
        "UndoExpense": lambda: [
            int(sanitize_input(request.form['TransactionID']))
        ],
        "AddDuesInstallment": lambda: [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['Year'])),
            float(sanitize_input(request.form['Amount']))
        ],
        "UndoDuesInstallment": lambda: [
            int(sanitize_input(request.form['PaymentID']))
        ],
        "PurchaseTicket": lambda: [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['SeatID'])),
            int(sanitize_input(request.form['PatronID'])) if request.form['PatronID'] else None,
            float(sanitize_input(request.form['Price']))
        ],
        "UndoTicketPurchase": lambda: [
            int(sanitize_input(request.form['TicketID']))
        ],
        "ListTicketsForProduction": lambda: [
            int(sanitize_input(request.form['ProductionID']))
        ],
        "GetMemberParticipation": lambda: [
            int(sanitize_input(request.form['MemberID']))
        ],
        # Below is for Reports
        "GetPlayListingReport": lambda: [],
        "GetProductionCastAndCrew": lambda: [
            int(sanitize_input(request.form['ProductionID']))
        ],
        "GetProductionSponsorTotal": lambda: [
            int(sanitize_input(request.form['ProductionID']))
        ],
        "GetPatronReport": lambda: [
            int(sanitize_input(request.form['PatronID']))
        ],
        "GetTicketSalesReport": lambda: [
            int(sanitize_input(request.form['ProductionID']))
        ],
        "GetMemberDuesReport": lambda: [],
        "GetProductionFinancialSummary": lambda: [
            int(sanitize_input(request.form['ProductionID'])) if request.form['ProductionID'] else None,
            sanitize_input(request.form['StartDate']) if request.form['StartDate'] else None,
            sanitize_input(request.form['EndDate']) if request.form['EndDate'] else None
        ],
        "SmartTicketPurchase": lambda: [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['PatronID'])),
            sanitize_input(request.form['SeatIDs']),  # Must be JSON string like "[101,102]"
            sanitize_input(request.form['Deadline']),
            float(sanitize_input(request.form['Price']))
        ],
        "SuggestAlternateSeats": lambda: [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['SeatCount']))
        ]
    }

    print(f"About to run call_procedure() with {action} and {args_map[action]}")
    if action not in args_map:
        return jsonify({"success": False, "error": f"Unknown procedure: {action}"})

    return call_procedure(action, args_map[action]())

@app.route('/function', methods=['POST'])
def function():
    if request.form.get("action") == "GetTotalDueForDues":
        dues_id = int(sanitize_input(request.form['DuesID']))
        return call_function("SELECT GetTotalDueForDues(%s)", (dues_id,))
    return jsonify({"success": False, "error": "Unknown function action"})

@app.route('/view', methods=['GET'])
def get_view():
    view_name = request.args.get('name')
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"SELECT * FROM {view_name}")
        result = cursor.fetchall()
        return jsonify({"success": True, "data": result})
    except Exception as e:
        return jsonify({"success": False, "error": str(e), "trace": traceback.format_exc()})
    finally:
        cursor.close()
        conn.close()

@app.route('/admin/import-csv', methods=['POST'])
def import_csv_route():
    admin_token = request.form.get("admin_token")
    expected_token = os.getenv("ADMIN_SECRET")

    if admin_token != expected_token:
        return jsonify({"success": False, "error": "Unauthorized"}), 403

    try:
        import_csv_data()
        return jsonify({"success": True, "message": "CSV data imported successfully."})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})
    
@app.route('/validate-id', methods=['POST'])
def validate_id():
    user_type = request.form.get('type')
    user_id = sanitize_input(request.form.get('id'))

    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        if user_type == "patron":
            cursor.execute("SELECT 1 FROM Patron WHERE PatronID = %s", (user_id,))
        elif user_type == "member":
            cursor.execute("SELECT 1 FROM Member WHERE MemberID = %s", (user_id,))
        else:
            return jsonify({"success": False, "error": "Invalid user type."})

        result = cursor.fetchone()
        if result:
            session.permanent = True
            session["user_type"] = user_type
            session["user_id"] = int(user_id)
            return jsonify({"success": True})
        else:
            return jsonify({"success": False, "error": "ID not found."})

    except Exception as e:
        return jsonify({"success": False, "error": str(e)})

    finally:
        cursor.close()
        conn.close()

@app.route('/login')
def login():
    return render_template('login.html')

@app.route('/admin')
def admin_page():
    if session.get("user_type") != "admin":
        return redirect('/')
    return render_template("admin.html")

@app.route('/patron/<int:patron_id>')
def patron_page(patron_id):
    if session.get("user_type") != "patron" or session.get("user_id") != patron_id:
        return redirect('/')
    return render_template("patron.html", patron_id=patron_id)

@app.route('/member/<int:member_id>')
def member_page(member_id):
    if session.get("user_type") != "member" or session.get("user_id") != member_id:
        return redirect('/')
    return render_template("member.html", member_id=member_id)

@app.route('/guest')
def guest_page():
    return render_template("guest.html")

app.secret_key = os.getenv("FLASK_SECRET_KEY", "supersecretkey")
app.permanent_session_lifetime = timedelta(hours=1)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))

# END OF DOC