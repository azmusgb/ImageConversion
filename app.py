from flask import Flask, request, jsonify, send_file, render_template
from PIL import Image, ImageEnhance, ImageOps
import os
import io
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['ALLOWED_EXTENSIONS'] = {'png', 'jpg', 'jpeg', 'gif'}
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///catalog.db'
db = SQLAlchemy(app)
class ImageCatalog(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    sku = db.Column(db.String(50), nullable=False)
    filename = db.Column(db.String(100), nullable=False)
    sharpness = db.Column(db.Float, default=1.0)
    brightness = db.Column(db.Float, default=1.0)
    contrast = db.Column(db.Float, default=1.0)
    color = db.Column(db.Float, default=1.0)
    rotate = db.Column(db.Float, default=0)
    resize_width = db.Column(db.Integer, nullable=True)
    resize_height = db.Column(db.Integer, nullable=True)
    crop = db.Column(db.PickleType, nullable=True)
    grayscale = db.Column(db.Boolean, default=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
def allowed_file(filename):
    return '.' in filename and filename.rsplit(
        '.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']
@app.route('/')
def index():
    return render_template('index.html')
@app.route('/upload', methods=['POST'])
def upload_file():
    sku = request.form.get('sku')
    file = request.files.get('file')
    if not sku or not file:
        return jsonify({'error': 'SKU and file are required'}), 400
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    if file and allowed_file(file.filename):
        filename = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
        file.save(filename)
        # Basic image processing
        image = Image.open(filename)
        sharpness = ImageEnhance.Sharpness(image)
        image = sharpness.enhance(2.0)
        # Save processed image
        processed_filename = f"processed_{file.filename}"
        processed_filepath = os.path.join(app.config['UPLOAD_FOLDER'],
                                          processed_filename)
        image.save(processed_filepath)
        # Save metadata to database
        new_entry = ImageCatalog(sku=sku,
                                 filename=processed_filename,
                                 sharpness=2.0,
                                 brightness=1.0,
                                 contrast=1.0,
                                 color=1.0,
                                 rotate=0,
                                 resize_width=None,
                                 resize_height=None,
                                 crop=None,
                                 grayscale=False)
        db.session.add(new_entry)
        db.session.commit()
        return jsonify({
            'message': 'File uploaded and processed successfully',
            'processed_image': processed_filename
        })
@app.route('/images/<filename>', methods=['GET'])
def get_image(filename):
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    if os.path.exists(filepath):
        return send_file(filepath, mimetype='image/jpeg')
    return jsonify({'error': 'File not found'}), 404
@app.route('/adjust', methods=['POST'])
def adjust_image():
    data = request.json
    filename = data.get('filename')
    sharpness_level = data.get('sharpness', 1.0)
    brightness_level = data.get('brightness', 1.0)
    contrast_level = data.get('contrast', 1.0)
    color_level = data.get('color', 1.0)
    rotate_angle = data.get('rotate', 0)
    resize_width = data.get('resize_width', None)
    resize_height = data.get('resize_height', None)
    crop_box = data.get('crop', None)
    grayscale = data.get('grayscale', False)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    if not os.path.exists(filepath):
        return jsonify({'error': 'File not found'}), 404
    image = Image.open(filepath)
    # Apply adjustments
    if grayscale:
        image = ImageOps.grayscale(image)
    sharpness = ImageEnhance.Sharpness(image)
    image = sharpness.enhance(sharpness_level)
    brightness = ImageEnhance.Brightness(image)
    image = brightness.enhance(brightness_level)
    contrast = ImageEnhance.Contrast(image)
    image = contrast.enhance(contrast_level)
    color = ImageEnhance.Color(image)
    image = color.enhance(color_level)
    if rotate_angle:
        image = image.rotate(rotate_angle, expand=True)
    if resize_width and resize_height:
        image = image.resize((resize_width, resize_height))
    if crop_box:
        image = image.crop(crop_box)
    # Save adjusted image
    adjusted_filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    image.save(adjusted_filepath)
    # Update metadata in database
    entry = ImageCatalog.query.filter_by(filename=filename).first()
    if entry:
        entry.sharpness = sharpness_level
        entry.brightness = brightness_level
        entry.contrast = contrast_level
        entry.color = color_level
        entry.rotate = rotate_angle
        entry.resize_width = resize_width
        entry.resize_height = resize_height
        entry.crop = crop_box
        entry.grayscale = grayscale
        db.session.commit()
    # Save processed image to a buffer for viewing
    img_io = io.BytesIO()
    image.save(img_io, 'JPEG')
    img_io.seek(0)
    return send_file(img_io, mimetype='image/jpeg')
@app.route('/catalog', methods=['GET'])
def get_catalog():
    images = ImageCatalog.query.all()
    catalog = []
    for image in images:
        catalog.append({
            'sku': image.sku,
            'filename': image.filename,
            'sharpness': image.sharpness,
            'brightness': image.brightness,
            'contrast': image.contrast,
            'color': image.color,
            'rotate': image.rotate,
            'resize_width': image.resize_width,
            'resize_height': image.resize_height,
            'crop': image.crop,
            'grayscale': image.grayscale,
            'timestamp': image.timestamp
                    })
        return jsonify(catalog)
if __name__ == '__main__':
    if not os.path.exists(app.config['UPLOAD_FOLDER']):
        os.makedirs(app.config['UPLOAD_FOLDER'])
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000)
    