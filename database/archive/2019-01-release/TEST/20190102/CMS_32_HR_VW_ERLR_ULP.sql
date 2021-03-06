--------------------------------------------------------
--  DDL for VW_ERLR_ULP
--------------------------------------------------------
CREATE OR REPLACE VIEW VW_ERLR_ULP
AS
SELECT
    U.ERLR_CASE_NUMBER
    , EC.ERLR_JOB_REQ_NUMBER
    , EC.PROCID    
    , EC.ERLR_CASE_CREATE_DT
    , ULP_RECEIPT_CHARGE_DT
	, CASE WHEN ULP_CHARGE_FILED_TIMELY = '1'  THEN 'Yes' ELSE 'No' END AS ULP_CHARGE_FILED_TIMELY
	, ULP_AGENCY_RESPONSE_DT
	, CASE WHEN ULP_FLRA_DOCUMENT_REUQESTED = '1'  THEN 'Yes' ELSE 'No' END AS ULP_FLRA_DOCUMENT_REUQESTED
	, ULP_DOC_SUBMISSION_FLRA_DT
	, ULP_DOCUMENT_DESCRIPTION
	, ULP_DISPOSITION_DT
	, ULP_DISPOSITION_TYPE
	, ULP_COMPLAINT_DT
	, ULP_AGENCY_ANSWER_DT
	, ULP_AGENCY_ANSWER_FILED_DT
	, ULP_SETTLEMENT_DISCUSSION_DT
	, ULP_PREHEARING_DISCLOSURE_DUE
	, ULP_PREHEARING_DISCLOSUE_DT
	, ULP_PREHEARING_CONFERENCE_DT
	, ULP_HEARING_DT
	, ULP_DECISION_DT
	, CASE WHEN ULP_EXCEPTION_FILED = '1'  THEN 'Yes' ELSE 'No' END AS ULP_EXCEPTION_FILED
	, ULP_EXCEPTION_FILED_DT
FROM
	ERLR_ULP U
    LEFT OUTER JOIN ERLR_CASE EC ON U.ERLR_CASE_NUMBER = EC.ERLR_CASE_NUMBER
;
/