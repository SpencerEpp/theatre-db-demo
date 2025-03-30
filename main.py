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
from import_csv_to_mysql import import_csv_data

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
        "CreatePlay": [
            sanitize_input(request.form['Title']),
            sanitize_input(request.form['Author']),
            sanitize_input(request.form['Genre']),
            int(sanitize_input(request.form['NumberOfActs'])),
            float(sanitize_input(request.form['Cost']))
        ],
        "UpdatePlay": [
            int(sanitize_input(request.form['PlayID'])),
            sanitize_input(request.form['Title']),
            sanitize_input(request.form['Author']),
            sanitize_input(request.form['Genre']),
            int(sanitize_input(request.form['NumberOfActs'])),
            float(sanitize_input(request.form['Cost']))
        ],
        "DeletePlay": [
            int(sanitize_input(request.form['PlayID']))
        ],
        "CreateMember": [
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Email']),
            sanitize_input(request.form['Phone']),
            sanitize_input(request.form['Address']),
            sanitize_input(request.form['Role'])
        ],
        "UpdateMember": [
            int(sanitize_input(request.form['MemberID'])),
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Email']),
            sanitize_input(request.form['Phone']),
            sanitize_input(request.form['Address']),
            sanitize_input(request.form['Role'])
        ],
        "DeleteMember": [
            int(sanitize_input(request.form['MemberID']))
        ],
        "AssignMemberToProduction": [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['ProductionID'])),
            sanitize_input(request.form['Role'])
        ],
        "RemoveMemberFromProduction": [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['ProductionID']))
        ],
        "CreateProduction": [
            sanitize_input(request.form['ProductionDate'])
        ],
        "UpdateProduction": [
            int(sanitize_input(request.form['ProductionID'])),
            sanitize_input(request.form['ProductionDate'])
        ],
        "DeleteProduction": [
            int(sanitize_input(request.form['ProductionID']))
        ],
        "LinkSponsorToProduction": [
            int(sanitize_input(request.form['SponsorID'])),
            int(sanitize_input(request.form['ProductionID'])),
            float(sanitize_input(request.form['Amount']))
        ],
        "UnlinkSponsorFromProduction": [
            int(sanitize_input(request.form['SponsorID'])),
            int(sanitize_input(request.form['ProductionID']))
        ],
        "CreateTicket": [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['SeatID'])),
            float(sanitize_input(request.form['Price'])),
            sanitize_input(request.form['ReservationDeadline']) if request.form['ReservationDeadline'] else None
        ],
        "ReleaseTicket": [
            int(sanitize_input(request.form['TicketID']))
        ],
        "UpdateTicketStatus": [
            int(sanitize_input(request.form['TicketID'])),
            sanitize_input(request.form['Status'])
        ],
        "UpdateTicketPrice": [
            int(sanitize_input(request.form['TicketID'])),
            float(sanitize_input(request.form['NewPrice']))
        ],
        "CancelReservation": [
            int(sanitize_input(request.form['TicketID']))
        ],
        "CreateSponsor": [
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Type'])
        ],
        "UpdateSponsor": [
            int(sanitize_input(request.form['SponsorID'])),
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Type'])
        ],
        "DeleteSponsor": [
            int(sanitize_input(request.form['SponsorID']))
        ],
        "CreatePatron": [
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Email']),
            sanitize_input(request.form['Address'])
        ],
        "UpdatePatron": [
            int(sanitize_input(request.form['PatronID'])),
            sanitize_input(request.form['Name']),
            sanitize_input(request.form['Email']),
            sanitize_input(request.form['Address'])
        ],
        "DeletePatron": [
            int(sanitize_input(request.form['PatronID']))
        ],
        "CreateMeeting": [
            sanitize_input(request.form['Type']),
            sanitize_input(request.form['Date'])
        ],
        "UpdateMeeting": [
            int(sanitize_input(request.form['MeetingID'])),
            sanitize_input(request.form['Type']),
            sanitize_input(request.form['Date'])
        ],
        "DeleteMeeting": [
            int(sanitize_input(request.form['MeetingID']))
        ],
        "AssignMemberToMeeting": [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['MeetingID']))
        ],
        "RemoveMemberFromMeeting": [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['MeetingID']))
        ],
        "CreateDuesRecord": [
            int(sanitize_input(request.form['MemberID'])),
            int(sanitize_input(request.form['Year'])),
            float(sanitize_input(request.form['TotalAmount']))
        ],
        "DeleteDuesRecord": [
            int(sanitize_input(request.form['DuesID']))
        ],
        "CheckSeatAvailability": [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['SeatID']))
        ],
        "ReserveTicket": [
            int(sanitize_input(request.form['TicketID'])),
            int(sanitize_input(request.form['PatronID'])),
            sanitize_input(request.form['Deadline']) if request.form['Deadline'] else None
        ],
        "CreateSeat": [
            sanitize_input(request.form['SeatRow']),
            int(sanitize_input(request.form['Number']))
        ],
        "UpdateSeat": [
            int(sanitize_input(request.form['SeatID'])),
            sanitize_input(request.form['SeatRow']),
            int(sanitize_input(request.form['Number']))
        ],
        "DeleteSeat": [
            int(sanitize_input(request.form['SeatID']))
        ],
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
        "ListTicketsForProduction": [
            int(sanitize_input(request.form['ProductionID']))
        ],
        "GetMemberParticipation": [
            int(sanitize_input(request.form['MemberID']))
        ],
        # Below is for Reports
        "GetPlayListingReport": [],
        "GetProductionCastAndCrew": [
            int(sanitize_input(request.form['ProductionID']))
        ],
        "GetProductionSponsors": [
            int(sanitize_input(request.form['ProductionID']))
        ],
        "GetPatronReport": [
            int(sanitize_input(request.form['PatronID']))
        ],
        "GetTicketSalesReport": [
            int(sanitize_input(request.form['ProductionID']))
        ],
        "GetMemberDuesReport": [],
        "GetProductionFinancialSummary": [
            int(sanitize_input(request.form['ProductionID'])) if request.form['ProductionID'] else None,
            sanitize_input(request.form['StartDate']) if request.form['StartDate'] else None,
            sanitize_input(request.form['EndDate']) if request.form['EndDate'] else None
        ],
        "SmartTicketPurchase": [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['PatronID'])),
            sanitize_input(request.form['SeatIDs']),  # Must be JSON string like "[101,102]"
            sanitize_input(request.form['Deadline']),
            float(sanitize_input(request.form['Price']))
        ],
        "SuggestAlternateSeats": [
            int(sanitize_input(request.form['ProductionID'])),
            int(sanitize_input(request.form['SeatCount']))
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

__all__ = ['db_config']

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))

# END OF DOC