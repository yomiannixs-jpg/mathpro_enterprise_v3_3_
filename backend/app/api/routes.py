from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
import random
import re
import sqlite3
from pathlib import Path

router = APIRouter()

BASE_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = BASE_DIR / 'data'
DB_PATH = DATA_DIR / 'mathpro_enterprise.db'


FIELDS = {
    "Primary Mathematics": [
        "Counting",
        "Addition",
        "Subtraction",
        "Multiplication",
        "Division",
        "Place Value",
        "Fractions",
        "Decimals",
        "Percentages",
        "Measurement",
        "Time",
        "Money Word Problems",
    ],
    "Arithmetic": [
        "Mental Math",
        "Word Problems",
        "Percentages",
        "Profit and Loss",
        "Ratio and Proportion",
        "Place Value",
        "Fractions",
        "Decimals",
        "Speed Distance Time",
        "Mixtures",
    ],
    "Algebra": [
        "Linear Equations",
        "Simultaneous Linear Equations",
        "Indices and Indicial Equations",
        "Quadratic Equations",
        "Inequalities",
        "Functions",
        "Polynomials",
        "Surds",
        "Logarithms",
        "Sequences",
    ],
    "Financial Mathematics": [
        "Future Value",
        "Present Value",
        "Time Value of Money",
        "Simple Interest",
        "Compound Interest",
        "Annuities",
        "Perpetuities",
        "Bonds",
        "Duration",
        "Convexity",
        "Black-Scholes",
        "Option Greeks",
    ],
    "Linear Algebra": [
        "Matrices",
        "Matrix Multiplication",
        "Matrix Determinants",
        "Determinants 2x2",
        "Determinants 3x3",
        "Determinants 4x4",
        "Eigenvalues",
        "Eigenvectors",
        "Vector Spaces",
        "Rank and Nullity",
        "Linear Transformations",
        "Diagonalization",
    ],
    "Trigonometry": [
        "Trigonometric Ratios",
        "Trigonometric Identities",
        "Inverse Trigonometry",
        "Sine Rule",
        "Cosine Rule",
        "Trigonometric Equations",
        "Radians",
        "Graphs of Trig Functions",
    ],
    "Geometry": [
        "Angles",
        "Triangles",
        "Quadrilaterals",
        "Transformations",
        "Geometry Word Problems",
        "Circle Geometry",
        "Coordinate Geometry",
        "Similarity and Congruence",
        "Mensuration",
        "Vectors in Geometry",
    ],
    "Calculus": [
        "Limits",
        "Differentiation",
        "Integration",
        "Applications of Differentiation",
        "Applications of Integration",
        "Series",
        "Optimization",
        "Multivariable Calculus",
        "Vector Calculus",
    ],
    "Differential Equations": [
        "First Order ODE",
        "Second Order ODE",
        "Systems of ODEs",
        "Laplace Transforms",
        "Stability",
        "Phase Plane",
    ],
    "PDE": [
        "Wave Equation",
        "Heat Equation",
        "Laplace Equation",
        "Separation of Variables",
        "Fourier Series",
        "Boundary Value Problems",
        "Green Functions",
        "Characteristics",
    ],
    "Integral Equations": [
        "Fredholm Equations",
        "Volterra Equations",
        "Kernels",
        "Resolvent Kernel",
        "Neumann Series",
    ],
    "Probability and Statistics": [
        "Descriptive Statistics",
        "Probability Rules",
        "Random Variables",
        "Binomial Distribution",
        "Normal Distribution",
        "Hypothesis Testing",
        "Regression",
        "Bayes Rule",
    ],
    "Operations Research": [
        "Linear Programming",
        "Transportation Problem",
        "Assignment Problem",
        "Network Models",
        "Inventory Models",
        "Queueing Theory",
    ],
    "Graduate Mathematics": [
        "Real Analysis",
        "Complex Analysis",
        "Measure Theory",
        "Functional Analysis",
        "Topology",
        "Abstract Algebra",
        "Dynamic Programming",
        "Stochastic Calculus",
        "Optimization Theory",
        "Numerical Analysis",
    ],
    "Olympiad Mathematics": [
        "Number Theory",
        "Combinatorics",
        "Olympiad Geometry",
        "Inequalities",
        "Functional Equations",
        "Sequences and Recurrences",
        "Graph Theory",
        "Modular Arithmetic",
        "Pigeonhole Principle",
        "Invariants",
    ],
}

LEVELS = [
    "Primary",
    "Junior Secondary",
    "Senior Secondary",
    "Undergraduate",
    "Graduate",
    "Exam Prep",
    "Olympiad",
]

EXAM_TRACKS = [
    "WAEC",
    "NECO",
    "JAMB",
    "SAT",
    "ACT",
    "GRE",
    "GMAT",
    "A-Level",
    "IB",
    "IMO Training",
]

DIFFICULTIES = ["easy", "medium", "hard", "expert", "olympiad"]

CLASSES = [
    {"id": "jss2", "name": "JSS 2 Mathematics", "students": 28, "accuracy": 74, "weak_topics": ["Percentages", "Word Problems"]},
    {"id": "ss2", "name": "SS 2 Further Maths", "students": 31, "accuracy": 81, "weak_topics": ["Trigonometric Identities", "Matrices"]},
    {"id": "uni1", "name": "University Year 1", "students": 25, "accuracy": 79, "weak_topics": ["Determinants 3x3", "Matrix Multiplication"]},
    {"id": "grad", "name": "Graduate Mathematics", "students": 16, "accuracy": 72, "weak_topics": ["Dynamic Programming", "Stochastic Calculus"]},
    {"id": "olympiad", "name": "Olympiad Training Group", "students": 18, "accuracy": 68, "weak_topics": ["Number Theory", "Combinatorics"]},
]

ASSIGNMENT_BANK = [
    {"id": "a1", "title": "Percentages and Profit/Loss Drill", "class_id": "jss2", "class_name": "JSS 2 Mathematics", "status": "active", "submitted": 18, "total": 28, "field": "Arithmetic", "topic": "Percentages", "level": "Junior Secondary", "difficulty": "medium", "question_count": 25},
    {"id": "a2", "title": "Trigonometric Identities Practice", "class_id": "ss2", "class_name": "SS 2 Further Maths", "status": "draft", "submitted": 0, "total": 31, "field": "Trigonometry", "topic": "Trigonometric Identities", "level": "Senior Secondary", "difficulty": "hard", "question_count": 20},
    {"id": "a3", "title": "Olympiad Modular Arithmetic Set", "class_id": "olympiad", "class_name": "Olympiad Training Group", "status": "active", "submitted": 12, "total": 18, "field": "Olympiad Mathematics", "topic": "Modular Arithmetic", "level": "Olympiad", "difficulty": "olympiad", "question_count": 15},
    {"id": "a4", "title": "Graduate Dynamic Programming Drill", "class_id": "grad", "class_name": "Graduate Mathematics", "status": "draft", "submitted": 0, "total": 16, "field": "Graduate Mathematics", "topic": "Dynamic Programming", "level": "Graduate", "difficulty": "expert", "question_count": 10},
]

SYSTEM_TASKS = [
    {"id": "payment", "title": "Review payment integration", "status": "open", "details": "Stripe, Paystack and Flutterwave payment adapters must be connected to subscription plans before production launch.", "recommendation": "Create sandbox keys first, then test Free, Pro, Premium, Olympiad and School plan upgrades."},
    {"id": "latex", "title": "Audit LaTeX rendering", "status": "open", "details": "Practice pages now use safe Math.tex expressions without wrapping delimiters. Continue adding topic-specific expressions.", "recommendation": "Use plain expressions such as u_{tt}=25u_{xx}, not \\(u_{tt}=25u_{xx}\\), when passing to Math.tex."},
    {"id": "question_bank", "title": "Expand field-aware question generators", "status": "open", "details": "v3.3 includes more field-aware generators and restores broad catalog coverage.", "recommendation": "Next add persistent template files and thousands of topic-level templates."},
    {"id": "assignment_preview", "title": "Review assignment preview workflow", "status": "open", "details": "Assignment preview buttons now open preview screens with sample questions.", "recommendation": "Next connect preview to publish, grading, timer, and student assignment-taking mode."},
]


def db_connection():
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def insert_assignment(cursor, assignment: dict):
    cursor.execute(
        """
        INSERT OR REPLACE INTO assignments (
            id, title, class_id, class_name, status, submitted, total,
            field, topic, level, difficulty, question_count,
            due_date, estimated_minutes
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            assignment["id"], assignment["title"], assignment["class_id"],
            assignment["class_name"], assignment["status"], assignment["submitted"],
            assignment["total"], assignment["field"], assignment["topic"],
            assignment["level"], assignment["difficulty"], assignment["question_count"],
            assignment.get("due_date", "No due date set"), assignment.get("estimated_minutes", max(10, assignment["question_count"] * 2)),
        ),
    )


def init_db():
    conn = db_connection()
    cur = conn.cursor()
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS assignments (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            class_id TEXT NOT NULL,
            class_name TEXT NOT NULL,
            status TEXT NOT NULL,
            submitted INTEGER NOT NULL,
            total INTEGER NOT NULL,
            field TEXT NOT NULL,
            topic TEXT NOT NULL,
            level TEXT NOT NULL,
            difficulty TEXT NOT NULL,
            question_count INTEGER NOT NULL,
            due_date TEXT NOT NULL,
            estimated_minutes INTEGER NOT NULL
        )
        """
    )
    cur.execute("SELECT COUNT(*) AS count FROM assignments")
    if cur.fetchone()["count"] == 0:
        for assignment in ASSIGNMENT_BANK:
            insert_assignment(cur, assignment)
    conn.commit()
    conn.close()


def get_all_assignments():
    init_db()
    conn = db_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM assignments ORDER BY rowid")
    rows = [dict(row) for row in cur.fetchall()]
    conn.close()
    return rows


def get_assignment(assignment_id: str):
    init_db()
    conn = db_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM assignments WHERE id = ?", (assignment_id,))
    row = cur.fetchone()
    conn.close()
    return dict(row) if row else None


class LoginRequest(BaseModel):
    name: str
    role: str

class QuestionRequest(BaseModel):
    level: str = "Senior Secondary"
    field: str = "Algebra"
    topic: str = "Linear Equations"
    difficulty: str = "medium"
    seed: int = 1

class TutorRequest(BaseModel):
    question: str
    ask: str = "Explain slowly"
    student_answer: Optional[str] = None

class AssignmentRequest(BaseModel):
    class_id: str
    title: str
    field: str
    topic: str
    level: str = "Senior Secondary"
    difficulty: str = "medium"
    question_count: int = 20
    due_date: Optional[str] = None

@router.get("/health")
def health():
    return {"status": "ok", "version": "enterprise-v4.0", "database": str(DB_PATH)}

@router.post("/auth/login")
def login(req: LoginRequest):
    role = req.role.lower().replace(" ", "_")
    if role not in ["student", "teacher", "institution_admin", "super_admin"]:
        raise HTTPException(status_code=400, detail="Invalid role")
    return {"token": f"demo-token-{role}", "user": {"name": req.name or "Demo User", "role": role, "plan": "Pro" if role == "student" else "School"}}

@router.get("/catalog")
def catalog():
    return {"levels": LEVELS, "exam_tracks": EXAM_TRACKS, "difficulties": DIFFICULTIES, "fields": FIELDS, "bank_size_per_topic": 5000}

@router.get("/student/dashboard")
def student_dashboard():
    return {"solved": 128, "accuracy": 82, "streak": 7, "bookmarks": 9, "weak_topics": ["Percentages", "Simultaneous Linear Equations", "Matrix Determinants"], "recommended": ["Word Problems", "Trigonometric Identities", "Dynamic Programming", "Stochastic Calculus", "Olympiad Number Theory"], "achievements": ["7-day streak", "Algebra Starter", "100 Questions Solved"]}

def payload(req, question, latex, hint, steps, answer):
    return {
        "question_text": question,
        "question_latex": latex,
        "hint_text": hint,
        "solution_steps": steps,
        "answer_text": answer,
        "field": req.field,
        "topic": req.topic,
        "difficulty": req.difficulty,
        "level": req.level,
        "bank_size": 5000,
        "seed": req.seed,
    }

def arithmetic_question(req, rng):
    if req.topic == "Word Problems":
        apples = rng.randint(12, 80); sold = rng.randint(3, apples // 2); bought = rng.randint(5, 40); ans = apples - sold + bought
        return payload(req, f"A shopkeeper had {apples} oranges. He sold {sold} and later bought {bought} more. How many oranges does he have now?", f"{apples}-{sold}+{bought}", "Subtract what was sold, then add what was bought.", [f"Start with {apples} oranges.", f"After selling {sold}: {apples}-{sold}={apples-sold}.", f"After buying {bought}: {apples-sold}+{bought}={ans}.", f"Answer: {ans} oranges."], f"{ans}")
    if req.topic == "Profit and Loss":
        cost = rng.randint(100, 900); profit = rng.randint(10, 45); selling = cost * (1 + profit / 100)
        return payload(req, f"An item costs {cost}. It is sold at a profit of {profit}%. Find the selling price.", f"{cost}(1+{profit}/100)", "Selling price = cost price × (1 + profit rate).", [f"Profit rate = {profit}% = {profit/100}.", f"Selling price = {cost}(1+{profit/100}).", f"Selling price = {selling:.2f}."], f"{selling:.2f}")
    total = rng.randint(80, 500); pct = rng.choice([5, 10, 12, 15, 20, 25, 30, 40]); ans = total * pct / 100
    return payload(req, f"Find {pct}% of {total}.", f"({pct}/100)\\times {total}", "Convert the percentage to a fraction over 100.", [f"{pct}% means {pct}/100.", f"{pct}% of {total} = ({pct}/100) × {total}.", f"Result = {ans:.2f}."], f"{ans:.2f}")

def algebra_question(req, rng):
    if "Simultaneous" in req.topic:
        x, y = rng.randint(1, 9), rng.randint(1, 9); a, b, c, d = rng.randint(1, 5), rng.randint(1, 5), rng.randint(1, 5), rng.randint(1, 5)
        e, f = a*x+b*y, c*x+d*y
        return payload(req, f"Solve the simultaneous equations: {a}x+{b}y={e} and {c}x+{d}y={f}.", f"{a}x+{b}y={e},\\quad {c}x+{d}y={f}", "Use elimination or substitution.", [f"Equation 1: {a}x+{b}y={e}.", f"Equation 2: {c}x+{d}y={f}.", "Eliminate one variable using multiplication/subtraction.", f"The solution is x={x}, y={y}.", "Check both equations by substitution."], f"x={x}, y={y}")
    if "Quadratic" in req.topic:
        r1, r2 = rng.randint(1, 8), rng.randint(1, 8); b = -(r1+r2); c = r1*r2
        return payload(req, f"Solve x^2 {b:+d}x {c:+d}=0.", f"x^2{b:+d}x{c:+d}=0", "Factor the quadratic using two numbers that multiply to the constant.", [f"We need two numbers with sum {r1+r2} and product {c}.", f"Those numbers are {r1} and {r2}.", f"So the factors are (x-{r1})(x-{r2})=0.", f"x={r1} or x={r2}."], f"x={r1} or x={r2}")
    if "Indices" in req.topic:
        a, m, n = rng.randint(2, 5), rng.randint(2, 5), rng.randint(2, 5)
        return payload(req, f"Simplify {a}^{m} × {a}^{n}.", f"{a}^{m}\\times {a}^{n}", "When bases are equal, add the powers.", [f"Same base: {a}.", f"Add powers: {m}+{n}={m+n}.", f"Therefore {a}^{m} × {a}^{n} = {a}^{m+n}."], f"{a}^{m+n}")
    A = rng.randint(2, 9); x = rng.randint(1, 12); B = rng.randint(-20, 20); C = A*x+B
    return payload(req, f"Solve for x: {A}x + ({B}) = {C}.", f"{A}x+({B})={C}", "Move the constant first, then divide.", [f"Start with {A}x + ({B}) = {C}.", f"Subtract {B}: {A}x = {C-B}.", f"Divide by {A}: x={x}."], f"x={x}")

def finance_question(req, rng):
    pv = rng.randint(500, 5000); r = rng.choice([0.05, 0.08, 0.10, 0.12]); n = rng.randint(2, 8); fv = pv*((1+r)**n)
    return payload(req, f"If PV={pv}, r={int(r*100)}%, and n={n}, compute the future value.", f"FV={pv}(1+{r})^{n}", "Use FV=PV(1+r)^n.", ["Future value is the accumulated amount.", f"FV={pv}(1+{r})^{n}.", f"FV={fv:.2f}."], f"{fv:.2f}")

def linear_algebra_question(req, rng):
    a,b,c,d = [rng.randint(1,7) for _ in range(4)]; det = a*d-b*c
    return payload(req, f"Find the determinant of the 2 by 2 matrix [{a}, {b}; {c}, {d}].", f"\\det(A)=({a})({d})-({b})({c})", "For 2 by 2 matrices, determinant = ad-bc.", [f"a={a}, b={b}, c={c}, d={d}.", f"det(A)=({a})({d})-({b})({c}).", f"det(A)={det}."], str(det))

def trig_question(req, rng):
    angle = rng.choice([30, 45, 60, 90]); values = {30:"1/2",45:"sqrt(2)/2",60:"sqrt(3)/2",90:"1"}
    return payload(req, f"Find sin({angle}°).", f"\\sin({angle}^\\circ)", "Use the standard trigonometric values.", [f"{angle}° is a standard angle.", f"From the standard table, sin({angle}°)={values[angle]}."], values[angle])

def geometry_question(req, rng):
    l,w = rng.randint(4,20), rng.randint(3,15)
    return payload(req, f"A rectangle has length {l} cm and width {w} cm. Find its area.", f"A={l}\\times {w}", "Area of rectangle = length × width.", [f"Area = {l} × {w}.", f"Area = {l*w} cm²."], f"{l*w} cm²")

def calculus_question(req, rng):
    n = rng.randint(2,6); a = rng.randint(2,9)
    return payload(req, f"Differentiate y = {a}x^{n}.", f"y={a}x^{n}", "Use the power rule: d/dx(ax^n)=anx^(n-1).", [f"Coefficient a={a}, power n={n}.", f"Multiply coefficient by power: {a}×{n}={a*n}.", f"Reduce the power by 1: {n}-1={n-1}.", f"dy/dx={a*n}x^{n-1}."], f"{a*n}x^{n-1}")

def pde_question(req, rng):
    c = rng.choice([4,9,16,25]); speed = int(c**0.5)
    return payload(req, f"For the wave equation u_tt = {c}u_xx, what is the wave speed?", f"u_{{tt}}={c}u_{{xx}}", "Compare with the standard form u_tt = v^2 u_xx.", [f"Standard wave equation: u_tt = v^2 u_xx.", f"Here v^2={c}.", f"So v=sqrt({c})={speed}."], str(speed))

def graduate_question(req, rng):
    if req.topic == "Dynamic Programming":
        beta = rng.choice([0.8, 0.9, 0.95]); payoff = rng.randint(5, 20); cont = rng.randint(10, 30); val = payoff + beta*cont
        return payload(req, f"Dynamic Programming: If V = max(a + beta W) with a={payoff}, beta={beta}, W={cont}, compute the continuation value.", f"V={payoff}+{beta}\\times {cont}", "Substitute into the Bellman continuation expression.", [f"Immediate payoff a={payoff}.", f"Discount factor beta={beta}.", f"Continuation payoff W={cont}.", f"V={payoff}+{beta}×{cont}={val:.2f}."], f"{val:.2f}")
    if req.topic == "Stochastic Calculus":
        mu = rng.choice([0.02, 0.05, 0.08]); sigma = rng.choice([0.1, 0.2, 0.3])
        return payload(req, f"Stochastic Calculus: For dS = mu S dt + sigma S dW with mu={mu} and sigma={sigma}, identify the drift and diffusion coefficients.", f"dS=\\mu Sdt+\\sigma SdW", "The coefficient of dt is the drift; the coefficient of dW is the diffusion.", [f"Drift term is mu S dt, so drift coefficient is {mu}.", f"Diffusion term is sigma S dW, so diffusion coefficient is {sigma}.", "These describe expected growth and random volatility respectively."], f"drift={mu}, diffusion={sigma}")
    return calculus_question(req, rng)

def olympiad_question(req, rng):
    n = rng.randint(5, 18); mod = rng.choice([3,5,7,9,11]); rem = (n*n+n)%mod
    return payload(req, f"Olympiad Number Theory: Find the remainder when n^2+n is divided by {mod}, where n={n}.", f"n^2+n\\pmod{{{mod}}}", "Compute n^2+n, then reduce modulo the divisor.", [f"Substitute n={n}: n^2+n={n}^2+{n}.", f"Compute: {n*n+n}.", f"Now divide by {mod} and take the remainder.", f"Remainder = {rem}."], str(rem))

@router.post("/question/generate")
def generate_question(req: QuestionRequest):
    rng = random.Random(f"{req.level}-{req.field}-{req.topic}-{req.difficulty}-{req.seed}")
    if req.field in ["Primary Mathematics", "Arithmetic"]: return arithmetic_question(req, rng)
    if req.field == "Algebra": return algebra_question(req, rng)
    if req.field == "Financial Mathematics": return finance_question(req, rng)
    if req.field == "Linear Algebra": return linear_algebra_question(req, rng)
    if req.field == "Trigonometry": return trig_question(req, rng)
    if req.field == "Geometry": return geometry_question(req, rng)
    if req.field == "Calculus": return calculus_question(req, rng)
    if req.field == "PDE": return pde_question(req, rng)
    if req.field == "Graduate Mathematics": return graduate_question(req, rng)
    if req.field == "Olympiad Mathematics" or req.level == "Olympiad": return olympiad_question(req, rng)
    return algebra_question(req, rng)

def solve_linear_two_variable_equation(text: str):
    compact = text.replace(" ", "")
    match = re.search(r"([+-]?\d*)x([+-]\d*)y=([+-]?\d+)", compact)
    if not match: return None
    a_raw,b_raw,c_raw = match.groups()
    def parse_coeff(raw):
        if raw in ["","+"]: return 1
        if raw == "-": return -1
        return int(raw)
    a,b,c = parse_coeff(a_raw), parse_coeff(b_raw), int(c_raw)
    if b == 0: return None
    return [f"We are solving the linear equation {a}x + {b}y = {c}.", "Because there is only one equation with two unknowns, there are infinitely many solutions unless another equation is supplied.", "We can express y in terms of x.", f"Move the x-term to the right side: {b}y = {c} - ({a})x.", f"Divide by {b}: y = ({c} - ({a})x)/{b}.", "To get a single numerical pair (x,y), we need one more independent equation."]

@router.post("/tutor/explain")
def tutor(req: TutorRequest):
    solved = solve_linear_two_variable_equation(req.question)
    if solved is not None:
        return {"reply": solved, "tone": "detailed step-by-step", "ask": req.ask}
    return {"reply": ["I will solve the problem step by step.", f"Problem received: {req.question}", "Step 1: Identify the unknown quantity or quantities.", "Step 2: Identify the relevant mathematical rule or formula.", "Step 3: Substitute the given values carefully.", "Step 4: Simplify one line at a time.", "Step 5: Check the final answer against the original problem."], "tone": "detailed step-by-step", "ask": req.ask}

@router.get("/teacher/dashboard")
def teacher_dashboard():
    return {"classes": CLASSES, "recent_activity": ["JSS 2 completed 420 arithmetic questions this week.", "SS 2 needs review work on trigonometric identities.", "University Year 1 improved determinant accuracy by 9 percentage points.", "Graduate Mathematics added Dynamic Programming and Stochastic Calculus.", "Olympiad Training Group completed modular arithmetic drills."], "assignments": get_all_assignments()}

@router.get("/teacher/assignments")
def teacher_assignments():
    return {"assignments": get_all_assignments()}

@router.get("/teacher/assignments/{assignment_id}")
def assignment_preview(assignment_id: str):
    assignment = get_assignment(assignment_id)
    if assignment is None:
        raise HTTPException(status_code=404, detail="Assignment not found")
    samples = []
    for i in range(1, min(assignment["question_count"], 5) + 1):
        req = QuestionRequest(level=assignment["level"], field=assignment["field"], topic=assignment["topic"], difficulty=assignment["difficulty"], seed=i)
        samples.append(generate_question(req))
    return {"assignment": assignment, "sample_questions": samples}

@router.get("/teacher/class/{class_id}")
def class_preview(class_id: str):
    class_item = next((c for c in CLASSES if c["id"] == class_id), None)
    if class_item is None:
        raise HTTPException(status_code=404, detail="Class not found")
    return {"class": class_item, "students": [{"name": "Ada", "accuracy": 92, "solved": 340, "weak_topic": "Word Problems", "status": "excellent"}, {"name": "Tunde", "accuracy": 67, "solved": 188, "weak_topic": "Percentages", "status": "needs review"}, {"name": "Mariam", "accuracy": 84, "solved": 265, "weak_topic": "Simultaneous Equations", "status": "good"}, {"name": "Chinedu", "accuracy": 71, "solved": 210, "weak_topic": "Profit and Loss", "status": "needs review"}, {"name": "Zainab", "accuracy": 76, "solved": 170, "weak_topic": "Olympiad Number Theory", "status": "developing"}], "recommendations": ["Assign 20 medium questions on weak topics.", "Review common errors before the next test.", "Use a mixed-difficulty drill after two days.", "For Olympiad students, add proof-based follow-up explanations."]}

@router.post("/teacher/assignments/create")
def create_assignment(req: AssignmentRequest):
    class_item = next((c for c in CLASSES if c["id"] == req.class_id), None)
    class_name = class_item["name"] if class_item else req.class_id
    new_assignment = {"id": f"assignment_{len(ASSIGNMENT_BANK)+1}", "title": req.title, "class_id": req.class_id, "class_name": class_name, "status": "saved", "submitted": 0, "total": class_item["students"] if class_item else 0, "field": req.field, "topic": req.topic, "level": req.level, "difficulty": req.difficulty, "question_count": req.question_count, "due_date": req.due_date or "No due date set", "estimated_minutes": max(10, req.question_count * 2)}
    ASSIGNMENT_BANK.append(new_assignment)
    return {"status": "saved", "assignment": new_assignment, "assignments": get_all_assignments()}

@router.get("/admin/dashboard")
def admin_dashboard():
    return {"institutions": 4, "teachers": 28, "students": 1240, "active_subscriptions": 312, "monthly_revenue_usd": 4280, "alerts": ["Two school licenses require renewal.", "JSS 2 Mathematics has weak performance in Percentages.", "Graduate Dynamic Programming and Stochastic Calculus added.", "Olympiad track needs more combinatorics templates."]}

@router.get("/subscriptions/plans")
def plans():
    return {"plans": [{"id": "free", "name": "Free", "price": 0, "features": ["20 questions/day", "Basic solutions"]}, {"id": "pro", "name": "Pro", "price": 7.99, "features": ["Unlimited practice", "AI Tutor", "Progress analytics"]}, {"id": "premium", "name": "Premium", "price": 14.99, "features": ["Mock exams", "Personalized study plan", "Priority AI"]}, {"id": "olympiad", "name": "Olympiad", "price": 19.99, "features": ["Olympiad drills", "Proof hints", "Advanced problem solving"]}, {"id": "school", "name": "School", "price": 499, "features": ["Teacher portal", "Class analytics", "Assignments"]}]}

@router.get("/super-admin/dashboard")
def super_admin():
    return {"system_status": "healthy", "total_users": 5320, "question_templates": 1120, "open_reports": 4, "tasks": SYSTEM_TASKS}

@router.get("/super-admin/tasks/{task_id}")
def task_detail(task_id: str):
    task = next((t for t in SYSTEM_TASKS if t["id"] == task_id), None)
    if task is None: raise HTTPException(status_code=404, detail="Task not found")
    return task
