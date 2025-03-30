import os
import csv
import mysql.connector

db_config = {
    'host': os.getenv('MYSQLHOST'),
    'user': os.getenv('MYSQLUSER'),
    'password': os.getenv('MYSQL_ROOT_PASSWORD'),
    'database': os.getenv('MYSQLDATABASE'),
    'port': int(os.getenv('MYSQLPORT', 3306))
}

csv_dir = "csv_data"  # Folder where your CSVs live (relative to project root)

# Define expected columns for each table
table_columns = {
    "Play": ["PlayID", "Title", "Author", "Genre", "NumberOfActs", "Cost"],
    "Production": ["ProductionID", "ProductionDate"],
    "Production_Play": ["ProductionID", "PlayID"],
    "Member": ["MemberID", "Name", "Email", "Phone", "Address", "Role"],
    "Member_Production": ["MemberID", "ProductionID", "Role"],
    "DuesOwed": ["DuesID", "MemberID", "Year", "TotalDue"],
    "DuesPayment": ["PaymentID", "DuesID", "AmountPaid", "PaymentDate"],
    "Sponsor": ["SponsorID", "Name", "Type"],
    "Production_Sponsor": ["ProductionID", "SponsorID", "ContributionAmount"],
    "Patron": ["PatronID", "Name", "Email", "Address"],
    "Seat": ["SeatID", "SeatRow", "Number"],
    "Ticket": ["TicketID", "ProductionID", "PatronID", "SeatID", "Price", "Status", "ReservationDeadline"],
    "Meeting": ["MeetingID", "Type", "Date"],
    "Member_Meeting": ["MemberID", "MeetingID"],
    "Financial_Transaction": [
        "TransactionID", "Type", "Amount", "Date", "Description",
        "DuesPaymentID", "TicketID", "SponsorID", "ProductionID"
    ]
}

def import_csv_data():
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    for table, columns in table_columns.items():
        csv_path = os.path.join(csv_dir, f"{table}.csv")
        if not os.path.exists(csv_path):
            print(f"Skipping {table}: CSV not found.")
            continue

        print(f"Importing data for table: {table}")
        with open(csv_path, "r", encoding="utf-8") as file:
            reader = csv.DictReader(file)
            reader.fieldnames = [name.strip() for name in reader.fieldnames] 
            for row in reader:
                try:
                    placeholders = ", ".join(["%s"] * len(columns))
                    column_names = ", ".join(columns)
                    values = [
                        row.get(col).strip() if row.get(col) and row.get(col).strip() != "" else None
                        for col in columns
                    ]
                    sql = f"INSERT INTO {table} ({column_names}) VALUES ({placeholders})"
                    cursor.execute(sql, values)
                except Exception as e:
                    print(f"Failed to insert row into {table}: {e}")
        conn.commit()

    cursor.close()
    conn.close()
    print("CSV data insertion complete.")

if __name__ == "__main__":
    import_csv_data()