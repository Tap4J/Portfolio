import os
import pandas as pd

directory = "C:/Users/jakub/Desktop/Portfolio/tableauData"

for filename in os.listdir(directory):
    if filename.endswith(".csv"):
        csv_file_path = os.path.join(directory, filename)
        excel_file_path = os.path.splitext(csv_file_path)[0] + ".xlsx"

        if os.path.exists(excel_file_path):
            os.remove(excel_file_path)
        data = pd.read_csv(csv_file_path)
    
        data.to_excel(excel_file_path, index=False)
        print(f"File with csv {csv_file_path} converted to {excel_file_path}")

print("All CSV files have been converted to XLSX.")