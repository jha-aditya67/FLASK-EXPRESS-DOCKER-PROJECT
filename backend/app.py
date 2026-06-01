from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.exceptions import BadRequest
import json

app = Flask(__name__)
CORS(app)


@app.route('/submit', methods=['POST'])
def submit():
    # Try to parse JSON safely and provide helpful error messages
    try:
        data = request.get_json(force=False, silent=False)
    except BadRequest:
        raw = request.get_data(as_text=True)
        try:
            data = json.loads(raw) if raw else {}
        except Exception as e:
            return jsonify({"message": "Invalid JSON", "error": str(e), "raw": raw}), 400

    if not isinstance(data, dict):
        return jsonify({"message": "Expected JSON object", "raw": data}), 400

    return jsonify({
        "message": "Data received successfully",
        "name": data.get("name"),
        "email": data.get("email")
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
