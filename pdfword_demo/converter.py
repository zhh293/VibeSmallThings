from pdf2docx import Converter

def convert_pdf_to_docx(input_path, output_path, start=0, end=None):
    try:
        cv = Converter(input_path)
        cv.convert(output_path, start=start, end=end)
        cv.close()
        return True
    except Exception:
        return False
