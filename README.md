# theatre-db-demo

This is a single-page Flask app to demo a fully interactive theatre database with stored procedures, triggers, and functions. All actions happen on `index.html`, with a live MySQL database hosted via Railway.<br>

---

## ACCESS GUIDE (For Teammates/Reviewers)

Visit the Live App: [theatre-db-demo-production.up.railway.app](https://theatre-db-demo-production.up.railway.app/)<br>

---

## Live Deployment (Railway + MySQL)
### What’s hosted:
- Flask app (`main.py`) → deployed on [Railway](https://railway.app)<br>
- MySQL database → provisioned via Railway MySQL plugin<br>
- Source code → hosted on GitHub<br>

| What            | Tool                                        |
|-----------------|---------------------------------------------|
| Backend         | Flask (`main.py`)                           |
| Frontend        | HTML/JS (`index.html`)                      |
| Database        | MySQL (via Railway plugin)                  |
| Hosting         | Railway (GitHub-linked)                     |
| Schema Import   | MySQL Workbench connection to Railway       |
| Data Import     | Data hosted on repo, import button on webapp|

---

## FULL SETUP GUIDE (From scratch)
### Required Downloads
- [Python 3.10+](https://www.python.org/downloads/)<br>
- [Node.js (for Railway CLI)](https://nodejs.org/)<br>
- [MySQL (Windows Installer)](https://dev.mysql.com/downloads/installer/)<br>
During MySQL install, select **MySQL Server**, **MySQL Shell**, **MySQL Workbench**.<br>

---

### Instructions

If you just want to edit the code follow steps 1-5, if you are deploying a new project follow all steps,
if you are updating the schema follow steps 7-10.<br>

1. Clone this repository, Run command: git clone https://github.com/yourusername/theatre-db-demo.git<br>
2. Cd to project, Run command: cd theatre-db-demo<br>

Note: 2 and 3 are optional but recommended.<br>
3. Run command: python -m venv venv<br>
4. Run command: venv\Scripts\activate<br>

5. Run command: pip install -r requirements.txt<br> 

6. Deploy Railway:<br> 
    a) Go to [https://railway.app](https://railway.app)<br>
    b) Create a new project and deploy it from your GitHub repo (main.py should be in project root folder)<br>
    c) Set the start command in repo settings on railway: python main.py<br>
    d) In the same settings you can generate URL or supply your own domain<br>
    e) Add a **MySQL Plugin** to the project<br>
    f) Go to your Flask service in Railway → `Variables` and add:<br>
        ```<br>
        MYSQLHOST = ${mysql.MYSQLHOST}<br>
        MYSQLUSER = ${mysql.MYSQLUSER}<br>
        MYSQLPASSWORD = ${mysql.MYSQLPASSWORD}<br>
        MYSQLDATABASE = ${mysql.MYSQLDATABASE}<br>
        MYSQLPORT = ${mysql.MYSQLPORT}<br>
        ```<br> 
    g) Deploy the project<br>

7. Open MySQL Workbench, and connect to the db (found in 'Connect to the database MySQL' under the data tab in the MySQL block)<br>
    - Connection Name: Railway<br>
    - Host name: metro.proxy.rlwy.net<br>
    - Port: 36017<br>
    - Username: root<br>
    - Password: ********* (ask spencer for password or get him to update schema)<br>

8. Open Railway connection and import theatre.sql<br>
9. Open schemas tab (bottom left) and right click on railway db, select 'Set as Default Schema'<br>
10. Shift + Ctrl + Enter to run sql file, this will import everything into the hosted db<br>

---

## Updating the Schema
If you want to **wipe and rebuild** the DB from `theatre.sql`:<br>

1. Follow steps 7-10 from above.<br>