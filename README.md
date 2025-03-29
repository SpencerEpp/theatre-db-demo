# theatre-db-demo

This is a single-page Flask app to demo a fully interactive theatre database with stored procedures, triggers, and functions. All actions happen on `index.html`, with a live MySQL database hosted via Railway.

---

## ACCESS GUIDE (For Teammates/Reviewers)

Visit the Live App: https://

---

## Live Deployment (Railway + MySQL)
### What’s hosted:
- Flask app (`app.py`) → deployed on [Railway](https://)
- MySQL database → provisioned via Railway MySQL plugin
- Source code → hosted on GitHub

| What            | Tool                      |
|-----------------|---------------------------|
| Backend         | Flask (`app.py`)          |
| Frontend        | HTML/JS (`index.html`)    |
| Database        | MySQL (via Railway plugin)|
| Hosting         | Railway (GitHub-linked)   |
| Schema Import   | Railway CLI               |

---

## FULL SETUP GUIDE (For Project Owner)
### Required Downloads
- [Python 3.10+](https://www.python.org/downloads/)
- [Node.js (for Railway CLI)](https://nodejs.org/)
- [MySQL Server (Windows Installer)](https://dev.mysql.com/downloads/installer/)
During MySQL install, select **MySQL Server** and **MySQL Shell** components only (Workbench optional).

---

## Setup
1. Clone this repository, Run command: git clone https://github.com/yourusername/theatre-db-demo.git
2. Cd to project, Run command: cd theatre-db-demo

Note: 2 and 3 are optional but recommended.
3. Run command: python -m venv venv 
4. Run command: venv\Scripts\activate

5. Run command: pip install -r requirements.txt 

6. Deploy Railway: 
    a) Go to [https://railway.app](https://railway.app)
    b) Create a new project and deploy it from your GitHub repo
    c) Add a **MySQL Plugin** to the project
    d) Go to your Flask service in Railway → `Variables` and add:
        ```
        MYSQLHOST = ${mysql.MYSQLHOST}
        MYSQLUSER = ${mysql.MYSQLUSER}
        MYSQLPASSWORD = ${mysql.MYSQLPASSWORD}
        MYSQLDATABASE = ${mysql.MYSQLDATABASE}
        MYSQLPORT = ${mysql.MYSQLPORT}
        ```
    e) Set the start command: python app.py 

7. Load the Database Schema (via Railway CLI + DBeaver):
    a) Run command in bash not venv: npm install -g @railway/cli
    b) Run command in bash: railway login
    c) Run command in bash: railway link
    d) Run command in bash: railway connect mysql
        > This will say: `Connected to mysql plugin on port 12345` — leave this terminal open!

8. Run the schema file:
    - Run command in bash: mysql -h nozomi.proxy.rlwy.net -u root -p **** --port 43504 --protocol=TCP railway  
    - Password has been hidden, discord spencer if you need it or have him update the schema

---

## Updating the Schema
If you want to **wipe and rebuild** the DB from `theatre.sql`:

1. Follow step 7 and 8 from above.