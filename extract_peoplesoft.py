import cx_Oracle
import pandas as pd

# Connection details (replace with your actual values or use environment variables)
ORACLE_HOST = 'your_oracle_host'
ORACLE_PORT = 1521
ORACLE_SID = 'your_sid'
ORACLE_USER = 'your_user'
ORACLE_PASSWORD = 'your_password'

DSN = cx_Oracle.makedsn(ORACLE_HOST, ORACLE_PORT, service_name=ORACLE_SID)

# Example queries for PeopleSoft tables
def extract_table(query, output_path):
    with cx_Oracle.connect(user=ORACLE_USER, password=ORACLE_PASSWORD, dsn=DSN) as conn:
        df = pd.read_sql(query, conn)
        df.to_csv(output_path, index=False)
        print(f"Extracted to {output_path}")

if __name__ == "__main__":
    # Student Career Term
    extract_table(
        """
        SELECT * FROM PS_STDNT_CAR_TERM
        """,
        "mock_data/ps_stdnt_car_term.csv"
    )
    # Academic Plan
    extract_table(
        """
        SELECT * FROM PS_ACAD_PLAN
        """,
        "mock_data/ps_acad_plan.csv"
    )
    # Student Enrollment
    extract_table(
        """
        SELECT * FROM PS_STDNT_ENRL
        """,
        "mock_data/ps_stdnt_enrl.csv"
    )
    # HR Personal Data
    extract_table(
        """
        SELECT * FROM PS_PERSONAL_DATA
        """,
        "mock_data/ps_personal_data.csv"
    )
    # HR Job
    extract_table(
        """
        SELECT * FROM PS_JOB
        """,
        "mock_data/ps_job.csv"
    )
    # Academic Advisor
    extract_table(
        """
        SELECT * FROM PS_ACAD_ADVISOR
        """,
        "mock_data/ps_acad_advisor.csv"
    )
    # Financial Aid
    extract_table(
        """
        SELECT * FROM PS_FINANCIAL_AID
        """,
        "mock_data/ps_financial_aid.csv"
    )
    # Financial Aid Item
    extract_table(
        """
        SELECT * FROM PS_FINANCIAL_AID_ITEM
        """,
        "mock_data/ps_financial_aid_item.csv"
    )
    # Financial Aid Term
    extract_table(
        """
        SELECT * FROM PS_FINANCIAL_AID_TERM
        """,
        "mock_data/ps_financial_aid_term.csv"
    ) 