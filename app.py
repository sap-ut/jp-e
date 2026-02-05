from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, login_user, login_required, logout_user, UserMixin
from datetime import datetime

app = Flask(__name__)
app.secret_key = "glass_erp_secret"
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
db = SQLAlchemy(app)

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = "login"

# ------------------- DATABASE MODELS -------------------
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True)
    password = db.Column(db.String(50))
    role = db.Column(db.String(20))  # admin / staff

class Party(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    contact = db.Column(db.String(20))
    jobcards = db.relationship('JobCard', backref='party', lazy=True)

class Item(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    rate_per_sqmt = db.Column(db.Float)
    jobcards = db.relationship('JobCard', backref='item', lazy=True)

class JobCard(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    party_id = db.Column(db.Integer, db.ForeignKey('party.id'))
    item_id = db.Column(db.Integer, db.ForeignKey('item.id'))
    length = db.Column(db.Float)
    width = db.Column(db.Float)
    holes = db.Column(db.Integer, default=0)
    big_holes = db.Column(db.Integer, default=0)
    add_charges = db.Column(db.Float, default=0)
    total_amount = db.Column(db.Float)
    date_created = db.Column(db.DateTime, default=datetime.now)
# ------------------------------------------------------

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# ------------------- LOGIN ROUTE -------------------
@app.route('/', methods=['GET','POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user = User.query.filter_by(username=username, password=password).first()
        if user:
            login_user(user)
            return redirect(url_for('index'))
        else:
            flash("Invalid Credentials")
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

# ------------------- INDEX (Single Page) -------------------
@app.route('/index', methods=['GET','POST'])
@login_required
def index():
    # PARTIES
    if request.method == 'POST' and 'name' in request.form:
        name = request.form['name']
        contact = request.form.get('contact','')
        new_party = Party(name=name, contact=contact)
        db.session.add(new_party)
        db.session.commit()
        flash("Party added successfully")
        return redirect(url_for('index'))

    # ITEMS
    if request.method == 'POST' and 'rate' in request.form:
        name = request.form['name']
        rate = float(request.form['rate'])
        new_item = Item(name=name, rate_per_sqmt=rate)
        db.session.add(new_item)
        db.session.commit()
        flash("Item added successfully")
        return redirect(url_for('index'))

    # JOBCARDS
    if request.method == 'POST' and 'length' in request.form:
        party_id = int(request.form['party'])
        item_id = int(request.form['item'])
        length = float(request.form['length'])
        width = float(request.form['width'])
        holes = int(request.form.get('holes',0))
        big_holes = int(request.form.get('big_holes',0))
        add_charges = float(request.form.get('add_charges',0))
        
        item = Item.query.get(item_id)
        base_amount = length * width * item.rate_per_sqmt
        hole_charge = holes * 10
        big_hole_charge = big_holes * 25
        total = base_amount + hole_charge + big_hole_charge + add_charges
        total_with_gst = total + total*0.18  # 18% GST
        
        jc = JobCard(
            party_id=party_id,
            item_id=item_id,
            length=length,
            width=width,
            holes=holes,
            big_holes=big_holes,
            add_charges=add_charges,
            total_amount=round(total_with_gst,2)
        )
        db.session.add(jc)
        db.session.commit()
        flash("Job Card Created")
        return redirect(url_for('index'))

    parties = Party.query.all()
    items = Item.query.all()
    jobcards = JobCard.query.order_by(JobCard.id.desc()).all()
    return render_template('index.html', parties=parties, items=items, jobcards=jobcards)

# ------------------- INIT DB -------------------
if __name__ == "__main__":
    db.create_all()
    # Create default admin if not exists
    if not User.query.filter_by(username="admin").first():
        db.session.add(User(username="admin", password="admin", role="admin"))
        db.session.commit()
    app.run(debug=True)
