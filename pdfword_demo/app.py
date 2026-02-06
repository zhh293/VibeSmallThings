import os
import uuid
from flask import Flask, render_template, request, send_file, redirect
from werkzeug.utils import secure_filename
from converter import convert_pdf_to_docx

app = Flask(__name__)

BASE_DIR = os.path.dirname(__file__)
UPLOAD_DIR = os.path.join(BASE_DIR, "uploads")
OUTPUT_DIR = os.path.join(BASE_DIR, "outputs")
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

ALLOWED_EXT = {"pdf"}

def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXT

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        if "file" not in request.files:
            return redirect("/")
        file = request.files["file"]
        if file.filename == "":
            return redirect("/")
        if file and allowed_file(file.filename):
            name = secure_filename(file.filename)
            uid = uuid.uuid4().hex
            input_path = os.path.join(UPLOAD_DIR, f"{uid}_{name}")
            file.save(input_path)
            output_name = f"{uid}_{os.path.splitext(name)[0]}.docx"
            output_path = os.path.join(OUTPUT_DIR, output_name)
            ok = convert_pdf_to_docx(input_path, output_path)
            if not ok:
                return "转换失败", 500
            return send_file(output_path, as_attachment=True)
        return redirect("/")
    return render_template("index.html")

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)
