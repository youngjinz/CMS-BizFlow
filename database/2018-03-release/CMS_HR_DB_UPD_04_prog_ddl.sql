
SET DEFINE OFF;





--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_ELIGQUAL
--------------------------------------------------------

/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * the Eligiblity and Qualification process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_PV_ELIGQUAL
(
	I_PROCID            IN      NUMBER
	, I_FIELD_DATA      IN      XMLTYPE
)
IS
	V_RLVNTDATANAME        VARCHAR2(100);
	V_VALUE                NVARCHAR2(2000);
	V_VALUE_LOOKUP         NVARCHAR2(2000);
	V_CURRENTDATE          DATE;
	V_CURRENTDATESTR       NVARCHAR2(30);
	V_VALUE_DATE           DATE;
	V_VALUE_DATESTR        NVARCHAR2(30);
	V_REC_CNT              NUMBER(10);
	V_XMLDOC               XMLTYPE;
	V_XMLVALUE             XMLTYPE;
BEGIN
	--DBMS_OUTPUT.PUT_LINE('==== SP_UPDATE_PV_ELIGQUAL ==============================');
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
	--DBMS_OUTPUT.PUT_LINE(' ----------------');
	--V_XMLDOC := XMLTYPE(I_FIELD_DATA);
	V_XMLDOC := I_FIELD_DATA;


	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		--DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

		V_RLVNTDATANAME := 'adminCode';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/ADMIN_CD/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'appointmentType';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/AT_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'cancelReason';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'candidateApproved';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/candidateApproved/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'candidateName';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/CNDT_FIRST_NM/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/CNDT_LAST_NM/text()');
		IF V_VALUE IS NOT NULL AND V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_VALUE || ' ' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'classSpecialist';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'classificationType';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CT_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'disqualReason';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/REVIEW/DISQUAL_REASON/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'eligQualCandidate';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/eligQualCandidate/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'execOfficer';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'feedbackDCO';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/feedbackDCO/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'feedbackStaffSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/feedbackStaffSpec/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'hrLiaison';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/HRL_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'ineligReason';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/REVIEW/INELIG_REASON/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'lastActivityCompDate';
		BEGIN
			SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
		EXCEPTION
			WHEN OTHERS THEN V_VALUE := NULL;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdClassSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdExecOff';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdHrLiaison';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/HRL_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdSelectOff';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdStaffSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posIs';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/SUPERVISORY/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posLocation';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/LOCATION/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posSensitivity';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/SEC_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posSeries';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/SERIES/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				--WHERE TBL_ID = TO_NUMBER(V_VALUE);
				WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = V_VALUE;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posTitle';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_TITLE/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'requestStatus';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatus/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'requestStatusDate';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatusDate/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			-------------------------------------
			-- even though it is date, do not format or perform GMT conversion
			-------------------------------------
			V_VALUE := V_VALUE;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'requestType';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/RT_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'returnToSO';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSO/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- This pv can be updated from multiple workitem
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'secondSubOrg';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/ADMIN_CD/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with admin code desc lookup value
			---------------------------------
			BEGIN
				SELECT AC_ADMIN_CD_DESCR INTO V_VALUE_LOOKUP
				FROM ADMIN_CODES
				WHERE AC_ADMIN_CD = SUBSTR(V_VALUE, 1, 3);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'selectOfficial';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'staffSpecialist';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			--V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
			-- If the Job Request is for Special Program, SS_ID may point to User Group,
			-- rather than individual user.  Therefore, lookup
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			BEGIN
				SELECT TYPE INTO V_VALUE_LOOKUP FROM BIZFLOW.MEMBER WHERE MEMBERID = V_VALUE;
			EXCEPTION
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;

			IF V_VALUE_LOOKUP IS NOT NULL THEN
				V_VALUE := '[' || V_VALUE_LOOKUP || ']' || V_XMLVALUE.GETSTRINGVAL();
			ELSE
				V_VALUE := NULL;
			END IF;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		--DBMS_OUTPUT.PUT_LINE('End PV update SP_UPDATE_PV_ELIGQUAL -------------------');

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_ELIGQUAL -------------------');
END;

/





--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_ELIGQUAL_TABLE
--------------------------------------------------------

/**
 * Parses Eligiblity and Qualification form XML data and stores it
 * into the operational tables for Eligiblity and Qualification.
 *
 * @param I_PROCID - Process ID
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_ELIGQUAL_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
	V_JOB_REQ_ID                NUMBER(20);
	V_JOB_REQ_NUM               NVARCHAR2(50);
	V_CLOBVALUE                 CLOB;
	V_VALUE                     NVARCHAR2(4000);
	V_VALUE_LOOKUP              NVARCHAR2(2000);
	V_REC_CNT                   NUMBER(10);
	V_XMLDOC                    XMLTYPE;
	V_XMLVALUE                  XMLTYPE;
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
	E_INVALID_PROCID            EXCEPTION;
	E_INVALID_JOB_REQ_ID        EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
	E_INVALID_STRATCON_DATA     EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_STRATCON_DATA, -20905);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_ELIGQUAL_TABLE - BEGIN ============================');
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE(' ----------------');


	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		------------------------------------------------------
		-- Transfer XML data into operational table
		--
		-- 1. Get Job Request Number
		-- 1.1 Select it from data xml from TBL_FORM_DTL table.
		-- 1.2 If not found, select it from BIZFLOW.RLVNTDATA table.
		-- 2. If Job Request Number not found, issue error.
		-- 3. For each target table,
		-- 3.1. If record found for the REQ_ID, update record.
		-- 3.2. If record not found for the REQ_ID, insert record.
		------------------------------------------------------
		--DBMS_OUTPUT.PUT_LINE('Starting xml data retrieval and table update ----------');

		--------------------------------
		-- get Job Request Number
		--------------------------------
		BEGIN
			SELECT XMLQUERY('/DOCUMENT/PROCESS_VARIABLE/requestNum/text()'
				PASSING FD.FIELD_DATA RETURNING CONTENT).GETSTRINGVAL()
				, FD.FIELD_DATA
			INTO V_JOB_REQ_NUM, V_XMLDOC
			FROM TBL_FORM_DTL FD
			WHERE FD.PROCID = I_PROCID;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_NUM := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (from xml) = ' || V_JOB_REQ_NUM);
		IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
			BEGIN
				SELECT VALUE
				INTO V_JOB_REQ_NUM
				FROM BIZFLOW.RLVNTDATA
				WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'requestNum';
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_JOB_REQ_NUM := NULL;
					RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request Number is invalid.  I_PROCID = '
						|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
			END;
		END IF;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (after pv check) = ' || V_JOB_REQ_NUM);
		IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request Number is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END IF;

		--------------------------------
		-- REQUEST table
		--------------------------------
		--DBMS_OUTPUT.PUT_LINE('    REQUEST table');
		BEGIN
			SELECT REQ_ID INTO V_JOB_REQ_ID
			FROM REQUEST
			WHERE REQ_JOB_REQ_NUMBER = V_JOB_REQ_NUM;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_ID := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('        V_JOB_REQ_ID = ' || V_JOB_REQ_ID);

		-- Unlike STRATCON, REQUEST record must be available by the time ELIGQUAL starts
		IF V_JOB_REQ_ID IS NULL THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request ID is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END IF;

		BEGIN
			--------------------------------
			-- REQUEST table update for cancellation
			--------------------------------
			MERGE INTO REQUEST TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS REQ_ID
					, V_JOB_REQ_NUM AS REQ_JOB_REQ_NUMBER
					, X.REQ_CANCEL_DT_STR
					, TO_DATE(X.REQ_CANCEL_DT_STR, 'YYYY/MM/DD HH24:MI:SS') AS REQ_CANCEL_DT
					, X.REQ_CANCEL_REASON
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/PROCESS_VARIABLE'
						PASSING FD.FIELD_DATA
						COLUMNS
							REQ_CANCEL_DT_STR                   NVARCHAR2(30)   PATH 'if (requestStatus/text() = "Request Cancelled") then requestStatusDate else ""'
							, REQ_CANCEL_REASON                 NVARCHAR2(140)  PATH 'cancelReason'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.REQ_ID = TRG.REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.REQ_CANCEL_DT           = SRC.REQ_CANCEL_DT
				, TRG.REQ_CANCEL_REASON     = SRC.REQ_CANCEL_REASON
			;
		END;


		BEGIN

			--------------------------------
			-- ELIG_QUAL table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    ELIG_QUAL table');
			MERGE INTO ELIG_QUAL TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS REQ_ID
					, I_PROCID AS PROCID

					, X.ADMIN_CD
					, X.RT_ID
					, X.AT_ID
					, X.VT_ID
					, X.SAT_ID
					, X.CT_ID
					, X.SO_ID
					, X.SO_TITLE
					, X.SO_ORG
					, X.XO_ID
					, X.XO_TITLE
					, X.XO_ORG
					, X.HRL_ID
					, X.HRL_TITLE
					, X.HRL_ORG
					, X.SS_ID
					, X.CS_ID
					, X.SO_AGREE
					, X.OTHER_CERT
					
					, X.CNDT_LAST_NM
					, X.CNDT_FIRST_NM
					, X.CNDT_MIDDLE_NM
					, X.BGT_APR_OFM
					, X.SPNSR_ORG_NM
					, X.SPNSR_ORG_FUND_PC
					, X.POS_TITLE
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = X.PAY_PLAN_ID AND ROWNUM = 1) AS PAY_PLAN_ID
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = X.SERIES AND ROWNUM = 1) AS SERIES
					, X.POS_DESC_NUMBER_1
					, X.CLASSIFICATION_DT_1
					, CASE WHEN LENGTH(X.GRADE_1) = 1 THEN '0' || X.GRADE_1 ELSE X.GRADE_1 END AS GRADE_1
					, X.POS_DESC_NUMBER_2
					, X.CLASSIFICATION_DT_2
					, CASE WHEN LENGTH(X.GRADE_2) = 1 THEN '0' || X.GRADE_2 ELSE X.GRADE_2 END AS GRADE_2
					, X.POS_DESC_NUMBER_3
					, X.CLASSIFICATION_DT_3
					, CASE WHEN LENGTH(X.GRADE_3) = 1 THEN '0' || X.GRADE_3 ELSE X.GRADE_3 END AS GRADE_3
					, X.POS_DESC_NUMBER_4
					, X.CLASSIFICATION_DT_4
					, CASE WHEN LENGTH(X.GRADE_4) = 1 THEN '0' || X.GRADE_4 ELSE X.GRADE_4 END AS GRADE_4
					, X.POS_DESC_NUMBER_5
					, X.CLASSIFICATION_DT_5
					, CASE WHEN LENGTH(X.GRADE_5) = 1 THEN '0' || X.GRADE_5 ELSE X.GRADE_5 END AS GRADE_5
					, X.MED_OFFICERS_ID
					, CASE WHEN LENGTH(X.PERFORMANCE_LEVEL) = 1 THEN '0' || X.PERFORMANCE_LEVEL ELSE X.PERFORMANCE_LEVEL END AS PERFORMANCE_LEVEL
					, X.SUPERVISORY
					, X.SKILL
					, X.LOCATION
					, X.VACANCIES
					, X.REPORT_SUPERVISOR
					, X.CAN
					, X.VICE
					, X.VICE_NAME
					, X.DAYS_ADVERTISED
					, X.TA_ID
					, X.NTE
					, X.WORK_SCHED_ID
					, X.HOURS_PER_WEEK
					, X.DUAL_EMPLMT
					, X.SEC_ID
					, X.CE_FINANCIAL_DISC
					, X.CE_FINANCIAL_TYPE_ID
					, X.CE_PE_PHYSICAL
					, X.CE_DRUG_TEST
					, X.CE_IMMUN
					, X.CE_TRAVEL
					, X.CE_TRAVEL_PER
					, X.CE_LIC
					, X.CE_LIC_INFO
					, X.REMARKS
					, X.PROC_REQ_TYPE
					, X.RECRUIT_OFFICE_ID
					, X.REQ_CREATE_NOTIFY_DT
					, X.ASSOC_DESCR_NUMBERS
					, X.PROMOTE_POTENTIAL
					, X.VICE_EMPL_ID
					, X.SR_ID
					, X.GR_ID
					, X.GA_1
					, X.GA_2
					, X.GA_3
					, X.GA_4
					, X.GA_5
					, X.GA_6
					, X.GA_7
					, X.GA_8
					, X.GA_9
					, X.GA_10
					, X.GA_11
					, X.GA_12
					, X.GA_13
					, X.GA_14
					, X.GA_15
					
					, X.CNDT_ELIGIBLE
					, X.INELIG_REASON
					, X.CNDT_QUALIFIED
					, X.DISQUAL_REASON

					, X.SEL_DETERM
					
					, X.DCO_CERT
					, X.DCO_NAME
					, X.DCO_SIG
					, X.DCO_SIG_DT

				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT'
						PASSING FD.FIELD_DATA
						COLUMNS
						
							ADMIN_CD                        NVARCHAR2(8)    PATH 'GENERAL/ADMIN_CD'
							, RT_ID                         NUMBER(20)      PATH 'GENERAL/RT_ID'
							, AT_ID                         NUMBER(20)      PATH 'GENERAL/AT_ID'
							, VT_ID                         NUMBER(20)      PATH 'GENERAL/VT_ID'
							, SAT_ID                        NUMBER(20)      PATH 'GENERAL/SAT_ID'
							, CT_ID                         NUMBER(20)      PATH 'GENERAL/CT_ID'
							, SO_ID                         NVARCHAR2(10)   PATH 'GENERAL/SO_ID'
							, SO_TITLE                      NVARCHAR2(50)   PATH 'GENERAL/SO_TITLE'
							, SO_ORG                        NVARCHAR2(50)   PATH 'GENERAL/SO_ORG'
							, XO_ID                         NVARCHAR2(10)   PATH 'GENERAL/XO_ID'
							, XO_TITLE                      NVARCHAR2(50)   PATH 'GENERAL/XO_TITLE'
							, XO_ORG                        NVARCHAR2(50)   PATH 'GENERAL/XO_ORG'
							, HRL_ID                        NVARCHAR2(10)   PATH 'GENERAL/HRL_ID'
							, HRL_TITLE                     NVARCHAR2(50)   PATH 'GENERAL/HRL_TITLE'
							, HRL_ORG                       NVARCHAR2(50)   PATH 'GENERAL/HRL_ORG'
							, SS_ID                         NVARCHAR2(10)   PATH 'GENERAL/SS_ID'
							, CS_ID                         NVARCHAR2(10)   PATH 'GENERAL/CS_ID'
							, SO_AGREE                      CHAR(1)         PATH 'if (GENERAL/SO_AGREE/text() = "true") then 1 else 0'
							, OTHER_CERT                    NVARCHAR2(200)  PATH 'GENERAL/OTHER_CERT'
							
							, CNDT_LAST_NM                  NVARCHAR2(50)   PATH 'POSITION/CNDT_LAST_NM'
							, CNDT_FIRST_NM                 NVARCHAR2(50)   PATH 'POSITION/CNDT_FIRST_NM'
							, CNDT_MIDDLE_NM                NVARCHAR2(50)   PATH 'POSITION/CNDT_MIDDLE_NM'
							, BGT_APR_OFM                   CHAR(1)         PATH 'POSITION/BGT_APR_OFM'
							, SPNSR_ORG_NM                  NVARCHAR2(140)  PATH 'POSITION/SPNSR_ORG_NM'
							, SPNSR_ORG_FUND_PC             NUMBER(3,0)     PATH 'POSITION/SPNSR_ORG_FUND_PC'
							, POS_TITLE                     NVARCHAR2(140)  PATH 'POSITION/POS_TITLE'
							, PAY_PLAN_ID                   VARCHAR2(140)   PATH 'POSITION/PAY_PLAN_ID'
							, SERIES                        VARCHAR2(140)   PATH 'POSITION/SERIES'
							, POS_DESC_NUMBER_1             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_1'
							, CLASSIFICATION_DT_1           DATE            PATH 'POSITION/CLASSIFICATION_DT_1'
							, GRADE_1                       VARCHAR2(2)     PATH 'POSITION/GRADE_1'
							, POS_DESC_NUMBER_2             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_2'
							, CLASSIFICATION_DT_2           DATE            PATH 'POSITION/CLASSIFICATION_DT_2'
							, GRADE_2                       VARCHAR2(2)     PATH 'POSITION/GRADE_2'
							, POS_DESC_NUMBER_3             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_3'
							, CLASSIFICATION_DT_3           DATE            PATH 'POSITION/CLASSIFICATION_DT_3'
							, GRADE_3                       VARCHAR2(2)     PATH 'POSITION/GRADE_3'
							, POS_DESC_NUMBER_4             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_4'
							, CLASSIFICATION_DT_4           DATE            PATH 'POSITION/CLASSIFICATION_DT_4'
							, GRADE_4                       VARCHAR2(2)     PATH 'POSITION/GRADE_4'
							, POS_DESC_NUMBER_5             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_5'
							, CLASSIFICATION_DT_5           DATE            PATH 'POSITION/CLASSIFICATION_DT_5'
							, GRADE_5                       VARCHAR2(2)     PATH 'POSITION/GRADE_5'
							, MED_OFFICERS_ID               NUMBER(20)      PATH 'POSITION/MED_OFFICERS_ID'
							, PERFORMANCE_LEVEL             NVARCHAR2(2)    PATH 'POSITION/PERFORMANCE_LEVEL'
							, SUPERVISORY                   NUMBER(20)      PATH 'POSITION/SUPERVISORY'
							, SKILL                         NVARCHAR2(200)  PATH 'POSITION/SKILL'
							, LOCATION                      NVARCHAR2(200)  PATH 'POSITION/LOCATION'
							, VACANCIES                     NUMBER(9)       PATH 'POSITION/VACANCIES'
							, REPORT_SUPERVISOR             NVARCHAR2(10)   PATH 'POSITION/REPORT_SUPERVISOR'
							, CAN                           NVARCHAR2(8)    PATH 'POSITION/CAN'
							, VICE                          CHAR(1)         PATH 'POSITION/VICE'
							, VICE_NAME                     NVARCHAR2(50)   PATH 'POSITION/VICE_NAME'
							, DAYS_ADVERTISED               NVARCHAR2(50)   PATH 'POSITION/DAYS_ADVERTISED'
							, TA_ID                         NUMBER(20)      PATH 'POSITION/TA_ID'
							, NTE                           NVARCHAR2(140)  PATH 'POSITION/NTE'
							, WORK_SCHED_ID                 NUMBER(20)      PATH 'POSITION/WORK_SCHED_ID'
							, HOURS_PER_WEEK                NVARCHAR2(50)   PATH 'POSITION/HOURS_PER_WEEK'
							, DUAL_EMPLMT                   NVARCHAR2(10)   PATH 'POSITION/DUAL_EMPLMT'
							, SEC_ID                        NUMBER(20)      PATH 'POSITION/SEC_ID'
							, CE_FINANCIAL_DISC             CHAR(1)         PATH 'if (POSITION/CE_FINANCIAL_DISC/text() = "true") then 1 else 0'
							, CE_FINANCIAL_TYPE_ID          NUMBER(20)      PATH 'POSITION/CE_FINANCIAL_TYPE_ID'
							, CE_PE_PHYSICAL                CHAR(1)         PATH 'if (POSITION/CE_PE_PHYSICAL/text() = "true") then 1 else 0'
							, CE_DRUG_TEST                  CHAR(1)         PATH 'if (POSITION/CE_DRUG_TEST/text() = "true") then 1 else 0'
							, CE_IMMUN                      CHAR(1)         PATH 'if (POSITION/CE_IMMUN/text() = "true") then 1 else 0'
							, CE_TRAVEL                     CHAR(1)         PATH 'if (POSITION/CE_TRAVEL/text() = "true") then 1 else 0'
							, CE_TRAVEL_PER                 NVARCHAR2(3)    PATH 'POSITION/CE_TRAVEL_PER'
							, CE_LIC                        CHAR(1)         PATH 'if (POSITION/CE_LIC/text() = "true") then 1 else 0'
							, CE_LIC_INFO                   NVARCHAR2(140)  PATH 'POSITION/CE_LIC_INFO'
							, REMARKS                       NVARCHAR2(500)  PATH 'POSITION/REMARKS'
							, PROC_REQ_TYPE                 NUMBER(20)      PATH 'POSITION/PROC_REQ_TYPE'
							, RECRUIT_OFFICE_ID             NUMBER(20)      PATH 'POSITION/RECRUIT_OFFICE_ID'
							, REQ_CREATE_NOTIFY_DT          DATE            PATH 'POSITION/REQ_CREATE_NOTIFY_DT'
							, ASSOC_DESCR_NUMBERS           NVARCHAR2(100)  PATH 'POSITION/ASSOC_DESCR_NUMBERS'
							, PROMOTE_POTENTIAL             NUMBER(2)       PATH 'POSITION/PROMOTE_POTENTIAL'
							, VICE_EMPL_ID                  NVARCHAR2(25)   PATH 'POSITION/VICE_EMPL_ID'
							, SR_ID                         NUMBER(20)      PATH 'POSITION/SR_ID'
							, GR_ID                         NUMBER(20)      PATH 'POSITION/GR_ID'
							, GA_1                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_1/text() = "true") then 1 else 0'
							, GA_2                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_2/text() = "true") then 1 else 0'
							, GA_3                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_3/text() = "true") then 1 else 0'
							, GA_4                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_4/text() = "true") then 1 else 0'
							, GA_5                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_5/text() = "true") then 1 else 0'
							, GA_6                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_6/text() = "true") then 1 else 0'
							, GA_7                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_7/text() = "true") then 1 else 0'
							, GA_8                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_8/text() = "true") then 1 else 0'
							, GA_9                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_9/text() = "true") then 1 else 0'
							, GA_10                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_10/text() = "true") then 1 else 0'
							, GA_11                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_11/text() = "true") then 1 else 0'
							, GA_12                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_12/text() = "true") then 1 else 0'
							, GA_13                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_13/text() = "true") then 1 else 0'
							, GA_14                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_14/text() = "true") then 1 else 0'
							, GA_15                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_15/text() = "true") then 1 else 0'

							, CNDT_ELIGIBLE                 NVARCHAR2(10)   PATH 'REVIEW/CNDT_ELIGIBLE'
							, INELIG_REASON                 NUMBER(20,0)    PATH 'REVIEW/INELIG_REASON'
							, CNDT_QUALIFIED                NVARCHAR2(10)   PATH 'REVIEW/CNDT_QUALIFIED'
							, DISQUAL_REASON                NUMBER(20,0)    PATH 'REVIEW/DISQUAL_REASON'

							, SEL_DETERM                    NUMBER(20,0)    PATH 'SELECTION/SEL_DETERM'
							
							, DCO_CERT                      NVARCHAR2(10)   PATH 'APPROVAL/DCO_CERT'
							, DCO_NAME                      NVARCHAR2(100)  PATH 'APPROVAL/DCO_NAME'
							, DCO_SIG                       NVARCHAR2(100)  PATH 'APPROVAL/DCO_SIG'
							, DCO_SIG_DT                    DATE            PATH 'APPROVAL/DCO_SIG_DT'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.REQ_ID = TRG.REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.PROCID       = SRC.PROCID

				, TRG.ADMIN_CD   = SRC.ADMIN_CD
				, TRG.RT_ID      = SRC.RT_ID
				, TRG.CT_ID      = SRC.CT_ID
				, TRG.AT_ID      = SRC.AT_ID
				, TRG.VT_ID      = SRC.VT_ID
				, TRG.SAT_ID     = SRC.SAT_ID
				, TRG.SO_ID      = SRC.SO_ID
				, TRG.SO_TITLE   = SRC.SO_TITLE
				, TRG.SO_ORG     = SRC.SO_ORG
				, TRG.XO_ID      = SRC.XO_ID
				, TRG.XO_TITLE   = SRC.XO_TITLE
				, TRG.XO_ORG     = SRC.XO_ORG
				, TRG.HRL_ID     = SRC.HRL_ID
				, TRG.HRL_TITLE  = SRC.HRL_TITLE
				, TRG.HRL_ORG    = SRC.HRL_ORG
				, TRG.SS_ID      = SRC.SS_ID
				, TRG.CS_ID      = SRC.CS_ID
				, TRG.SO_AGREE   = SRC.SO_AGREE
				, TRG.OTHER_CERT = SRC.OTHER_CERT

				, TRG.CNDT_LAST_NM          = SRC.CNDT_LAST_NM
				, TRG.CNDT_FIRST_NM         = SRC.CNDT_FIRST_NM
				, TRG.CNDT_MIDDLE_NM        = SRC.CNDT_MIDDLE_NM
				, TRG.BGT_APR_OFM           = SRC.BGT_APR_OFM
				, TRG.SPNSR_ORG_NM          = SRC.SPNSR_ORG_NM
				, TRG.SPNSR_ORG_FUND_PC     = SRC.SPNSR_ORG_FUND_PC
				, TRG.POS_TITLE             = SRC.POS_TITLE
				, TRG.PAY_PLAN_ID           = SRC.PAY_PLAN_ID
				, TRG.SERIES                = SRC.SERIES
				, TRG.POS_DESC_NUMBER_1     = SRC.POS_DESC_NUMBER_1
				, TRG.CLASSIFICATION_DT_1   = SRC.CLASSIFICATION_DT_1
				, TRG.GRADE_1               = SRC.GRADE_1
				, TRG.POS_DESC_NUMBER_2     = SRC.POS_DESC_NUMBER_2
				, TRG.CLASSIFICATION_DT_2   = SRC.CLASSIFICATION_DT_2
				, TRG.GRADE_2               = SRC.GRADE_2
				, TRG.POS_DESC_NUMBER_3     = SRC.POS_DESC_NUMBER_3
				, TRG.CLASSIFICATION_DT_3   = SRC.CLASSIFICATION_DT_3
				, TRG.GRADE_3               = SRC.GRADE_3
				, TRG.POS_DESC_NUMBER_4     = SRC.POS_DESC_NUMBER_4
				, TRG.CLASSIFICATION_DT_4   = SRC.CLASSIFICATION_DT_4
				, TRG.GRADE_4               = SRC.GRADE_4
				, TRG.POS_DESC_NUMBER_5     = SRC.POS_DESC_NUMBER_5
				, TRG.CLASSIFICATION_DT_5   = SRC.CLASSIFICATION_DT_5
				, TRG.GRADE_5               = SRC.GRADE_5
				, TRG.MED_OFFICERS_ID       = SRC.MED_OFFICERS_ID
				, TRG.PERFORMANCE_LEVEL     = SRC.PERFORMANCE_LEVEL
				, TRG.SUPERVISORY           = SRC.SUPERVISORY
				, TRG.SKILL                 = SRC.SKILL
				, TRG.LOCATION              = SRC.LOCATION
				, TRG.VACANCIES             = SRC.VACANCIES
				, TRG.REPORT_SUPERVISOR     = SRC.REPORT_SUPERVISOR
				, TRG.CAN                   = SRC.CAN
				, TRG.VICE                  = SRC.VICE
				, TRG.VICE_NAME             = SRC.VICE_NAME
				, TRG.DAYS_ADVERTISED       = SRC.DAYS_ADVERTISED
				, TRG.TA_ID                 = SRC.TA_ID
				, TRG.NTE                   = SRC.NTE
				, TRG.WORK_SCHED_ID         = SRC.WORK_SCHED_ID
				, TRG.HOURS_PER_WEEK        = SRC.HOURS_PER_WEEK
				, TRG.DUAL_EMPLMT           = SRC.DUAL_EMPLMT
				, TRG.SEC_ID                = SRC.SEC_ID
				, TRG.CE_FINANCIAL_DISC     = SRC.CE_FINANCIAL_DISC
				, TRG.CE_FINANCIAL_TYPE_ID  = SRC.CE_FINANCIAL_TYPE_ID
				, TRG.CE_PE_PHYSICAL        = SRC.CE_PE_PHYSICAL
				, TRG.CE_DRUG_TEST          = SRC.CE_DRUG_TEST
				, TRG.CE_IMMUN              = SRC.CE_IMMUN
				, TRG.CE_TRAVEL             = SRC.CE_TRAVEL
				, TRG.CE_TRAVEL_PER         = SRC.CE_TRAVEL_PER
				, TRG.CE_LIC                = SRC.CE_LIC
				, TRG.CE_LIC_INFO           = SRC.CE_LIC_INFO
				, TRG.REMARKS               = SRC.REMARKS
				, TRG.PROC_REQ_TYPE         = SRC.PROC_REQ_TYPE
				, TRG.RECRUIT_OFFICE_ID     = SRC.RECRUIT_OFFICE_ID
				, TRG.REQ_CREATE_NOTIFY_DT  = SRC.REQ_CREATE_NOTIFY_DT
				, TRG.ASSOC_DESCR_NUMBERS   = SRC.ASSOC_DESCR_NUMBERS
				, TRG.PROMOTE_POTENTIAL     = SRC.PROMOTE_POTENTIAL
				, TRG.VICE_EMPL_ID          = SRC.VICE_EMPL_ID
				, TRG.SR_ID                 = SRC.SR_ID
				, TRG.GR_ID                 = SRC.GR_ID
				, TRG.GA_1                  = SRC.GA_1
				, TRG.GA_2                  = SRC.GA_2
				, TRG.GA_3                  = SRC.GA_3
				, TRG.GA_4                  = SRC.GA_4
				, TRG.GA_5                  = SRC.GA_5
				, TRG.GA_6                  = SRC.GA_6
				, TRG.GA_7                  = SRC.GA_7
				, TRG.GA_8                  = SRC.GA_8
				, TRG.GA_9                  = SRC.GA_9
				, TRG.GA_10                 = SRC.GA_10
				, TRG.GA_11                 = SRC.GA_11
				, TRG.GA_12                 = SRC.GA_12
				, TRG.GA_13                 = SRC.GA_13
				, TRG.GA_14                 = SRC.GA_14
				, TRG.GA_15                 = SRC.GA_15
				
				, TRG.CNDT_ELIGIBLE         = SRC.CNDT_ELIGIBLE
				, TRG.INELIG_REASON         = SRC.INELIG_REASON
				, TRG.CNDT_QUALIFIED        = SRC.CNDT_QUALIFIED
				, TRG.DISQUAL_REASON        = SRC.DISQUAL_REASON

				, TRG.SEL_DETERM            = SRC.SEL_DETERM
				
				, TRG.DCO_CERT              = SRC.DCO_CERT
				, TRG.DCO_NAME              = SRC.DCO_NAME
				, TRG.DCO_SIG               = SRC.DCO_SIG
				, TRG.DCO_SIG_DT            = SRC.DCO_SIG_DT

			WHEN NOT MATCHED THEN INSERT
			(
				TRG.REQ_ID
				, TRG.PROCID

				, TRG.ADMIN_CD
				, TRG.RT_ID
				, TRG.CT_ID
				, TRG.AT_ID
				, TRG.VT_ID
				, TRG.SAT_ID
				, TRG.SO_ID
				, TRG.SO_TITLE
				, TRG.SO_ORG
				, TRG.XO_ID
				, TRG.XO_TITLE
				, TRG.XO_ORG
				, TRG.HRL_ID
				, TRG.HRL_TITLE
				, TRG.HRL_ORG
				, TRG.SS_ID
				, TRG.CS_ID
				, TRG.SO_AGREE
				, TRG.OTHER_CERT
				
				, TRG.CNDT_LAST_NM
				, TRG.CNDT_FIRST_NM
				, TRG.CNDT_MIDDLE_NM
				, TRG.BGT_APR_OFM
				, TRG.SPNSR_ORG_NM
				, TRG.SPNSR_ORG_FUND_PC
				, TRG.POS_TITLE
				, TRG.PAY_PLAN_ID
				, TRG.SERIES
				, TRG.POS_DESC_NUMBER_1
				, TRG.CLASSIFICATION_DT_1
				, TRG.GRADE_1
				, TRG.POS_DESC_NUMBER_2
				, TRG.CLASSIFICATION_DT_2
				, TRG.GRADE_2
				, TRG.POS_DESC_NUMBER_3
				, TRG.CLASSIFICATION_DT_3
				, TRG.GRADE_3
				, TRG.POS_DESC_NUMBER_4
				, TRG.CLASSIFICATION_DT_4
				, TRG.GRADE_4
				, TRG.POS_DESC_NUMBER_5
				, TRG.CLASSIFICATION_DT_5
				, TRG.GRADE_5
				, TRG.MED_OFFICERS_ID
				, TRG.PERFORMANCE_LEVEL
				, TRG.SUPERVISORY
				, TRG.SKILL
				, TRG.LOCATION
				, TRG.VACANCIES
				, TRG.REPORT_SUPERVISOR
				, TRG.CAN
				, TRG.VICE
				, TRG.VICE_NAME
				, TRG.DAYS_ADVERTISED
				, TRG.TA_ID
				, TRG.NTE
				, TRG.WORK_SCHED_ID
				, TRG.HOURS_PER_WEEK
				, TRG.DUAL_EMPLMT
				, TRG.SEC_ID
				, TRG.CE_FINANCIAL_DISC
				, TRG.CE_FINANCIAL_TYPE_ID
				, TRG.CE_PE_PHYSICAL
				, TRG.CE_DRUG_TEST
				, TRG.CE_IMMUN
				, TRG.CE_TRAVEL
				, TRG.CE_TRAVEL_PER
				, TRG.CE_LIC
				, TRG.CE_LIC_INFO
				, TRG.REMARKS
				, TRG.PROC_REQ_TYPE
				, TRG.RECRUIT_OFFICE_ID
				, TRG.REQ_CREATE_NOTIFY_DT
				, TRG.ASSOC_DESCR_NUMBERS
				, TRG.PROMOTE_POTENTIAL
				, TRG.VICE_EMPL_ID
				, TRG.SR_ID
				, TRG.GR_ID
				, TRG.GA_1
				, TRG.GA_2
				, TRG.GA_3
				, TRG.GA_4
				, TRG.GA_5
				, TRG.GA_6
				, TRG.GA_7
				, TRG.GA_8
				, TRG.GA_9
				, TRG.GA_10
				, TRG.GA_11
				, TRG.GA_12
				, TRG.GA_13
				, TRG.GA_14
				, TRG.GA_15
				
				, TRG.CNDT_ELIGIBLE
				, TRG.INELIG_REASON
				, TRG.CNDT_QUALIFIED
				, TRG.DISQUAL_REASON

				, TRG.SEL_DETERM
				
				, TRG.DCO_CERT
				, TRG.DCO_NAME
				, TRG.DCO_SIG
				, TRG.DCO_SIG_DT
			)
			VALUES
			(
				SRC.REQ_ID
				, SRC.PROCID

				, SRC.ADMIN_CD
				, SRC.RT_ID
				, SRC.CT_ID
				, SRC.AT_ID
				, SRC.VT_ID
				, SRC.SAT_ID
				, SRC.SO_ID
				, SRC.SO_TITLE
				, SRC.SO_ORG
				, SRC.XO_ID
				, SRC.XO_TITLE
				, SRC.XO_ORG
				, SRC.HRL_ID
				, SRC.HRL_TITLE
				, SRC.HRL_ORG
				, SRC.SS_ID
				, SRC.CS_ID
				, SRC.SO_AGREE
				, SRC.OTHER_CERT

				, SRC.CNDT_LAST_NM
				, SRC.CNDT_FIRST_NM
				, SRC.CNDT_MIDDLE_NM
				, SRC.BGT_APR_OFM
				, SRC.SPNSR_ORG_NM
				, SRC.SPNSR_ORG_FUND_PC
				, SRC.POS_TITLE
				, SRC.PAY_PLAN_ID
				, SRC.SERIES
				, SRC.POS_DESC_NUMBER_1
				, SRC.CLASSIFICATION_DT_1
				, SRC.GRADE_1
				, SRC.POS_DESC_NUMBER_2
				, SRC.CLASSIFICATION_DT_2
				, SRC.GRADE_2
				, SRC.POS_DESC_NUMBER_3
				, SRC.CLASSIFICATION_DT_3
				, SRC.GRADE_3
				, SRC.POS_DESC_NUMBER_4
				, SRC.CLASSIFICATION_DT_4
				, SRC.GRADE_4
				, SRC.POS_DESC_NUMBER_5
				, SRC.CLASSIFICATION_DT_5
				, SRC.GRADE_5
				, SRC.MED_OFFICERS_ID
				, SRC.PERFORMANCE_LEVEL
				, SRC.SUPERVISORY
				, SRC.SKILL
				, SRC.LOCATION
				, SRC.VACANCIES
				, SRC.REPORT_SUPERVISOR
				, SRC.CAN
				, SRC.VICE
				, SRC.VICE_NAME
				, SRC.DAYS_ADVERTISED
				, SRC.TA_ID
				, SRC.NTE
				, SRC.WORK_SCHED_ID
				, SRC.HOURS_PER_WEEK
				, SRC.DUAL_EMPLMT
				, SRC.SEC_ID
				, SRC.CE_FINANCIAL_DISC
				, SRC.CE_FINANCIAL_TYPE_ID
				, SRC.CE_PE_PHYSICAL
				, SRC.CE_DRUG_TEST
				, SRC.CE_IMMUN
				, SRC.CE_TRAVEL
				, SRC.CE_TRAVEL_PER
				, SRC.CE_LIC
				, SRC.CE_LIC_INFO
				, SRC.REMARKS
				, SRC.PROC_REQ_TYPE
				, SRC.RECRUIT_OFFICE_ID
				, SRC.REQ_CREATE_NOTIFY_DT
				, SRC.ASSOC_DESCR_NUMBERS
				, SRC.PROMOTE_POTENTIAL
				, SRC.VICE_EMPL_ID
				, SRC.SR_ID
				, SRC.GR_ID
				, SRC.GA_1
				, SRC.GA_2
				, SRC.GA_3
				, SRC.GA_4
				, SRC.GA_5
				, SRC.GA_6
				, SRC.GA_7
				, SRC.GA_8
				, SRC.GA_9
				, SRC.GA_10
				, SRC.GA_11
				, SRC.GA_12
				, SRC.GA_13
				, SRC.GA_14
				, SRC.GA_15
				
				, SRC.CNDT_ELIGIBLE
				, SRC.INELIG_REASON
				, SRC.CNDT_QUALIFIED
				, SRC.DISQUAL_REASON

				, SRC.SEL_DETERM
				
				, SRC.DCO_CERT
				, SRC.DCO_NAME
				, SRC.DCO_SIG
				, SRC.DCO_SIG_DT
			)
			;

		EXCEPTION
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20905, 'SP_UPDATE_ELIGQUAL_TABLE: Invalid ELIGQUAL data.  I_PROCID = '
					|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END;

		--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_ELIGQUAL_TABLE - END ==========================');

	END IF;

EXCEPTION
	WHEN E_INVALID_PROCID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
	WHEN E_INVALID_JOB_REQ_ID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
	WHEN E_INVALID_STRATCON_DATA THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
END;

/






--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_FORM_DATA
--------------------------------------------------------

/**
 * Stores the form data XML in the form detail table (TBL_FORM_DTL).
 *
 * @param IO_ID - ID number the row of the TBL_FORM_DTL table to be inserted or updated.  It will be also used as the return object.
 * @param I_FORM_TYPE - Form Type to indicate the source form name, which will be
 * 				used to distinguish the xml structure.
 * @param I_FIELD_DATA - CLOB representation of the form xml data.
 * @param I_USER - Indicates the user who
 * @param I_PROCID - Process ID for the process instance associated with the given form data.
 * @param I_ACTSEQ - Activity Sequence for the process instance associated with the given form data.
 * @param I_WITEMSEQ - Work Item Sequence for the process instance associated with the given form data.
 *
 * @return IO_ID - ID number of the row of the TBL_FORM_DTL table inserted or updated.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_FORM_DATA
(
	IO_ID               IN OUT  NUMBER
	, I_FORM_TYPE       IN      VARCHAR2
	, I_FIELD_DATA      IN      CLOB
	, I_USER            IN      VARCHAR2
	, I_PROCID          IN      NUMBER
	, I_ACTSEQ          IN      NUMBER
	, I_WITEMSEQ        IN      NUMBER
)
IS
	V_ID                    NUMBER(20);
	V_FORM_TYPE             VARCHAR2(50);
	V_USER                  VARCHAR2(50);
	V_PROCID                NUMBER(10);
	V_ACTSEQ                NUMBER(10);
	V_WITEMSEQ              NUMBER(10);
	V_REC_CNT               NUMBER(10);
	V_MAX_ID                NUMBER(20);
	V_XMLDOC                XMLTYPE;
	V_REQ_FORM_FIELD_XPATH  VARCHAR2(100);
	V_REQ_FORM_FIELD_PREV	VARCHAR2(500);	
	V_REQ_FORM_FIELD        VARCHAR2(500);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    ID IS NULL?  = ' || (CASE WHEN IO_ID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    ID           = ' || TO_CHAR(IO_ID));
	--DBMS_OUTPUT.PUT_LINE('    I_FORM_TYPE  = ' || I_FORM_TYPE);
	--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA = ' || I_FIELD_DATA);
	--DBMS_OUTPUT.PUT_LINE('    I_USER       = ' || I_USER);
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID     = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    I_ACTSEQ     = ' || TO_CHAR(I_ACTSEQ));
	--DBMS_OUTPUT.PUT_LINE('    I_WITEMSEQ   = ' || TO_CHAR(I_WITEMSEQ));
	--DBMS_OUTPUT.PUT_LINE(' ----------------');
	
	-- sanity check: ignore and exit if form data xml is null or empty
	IF I_FIELD_DATA IS NULL OR LENGTH(I_FIELD_DATA) <= 0 THEN
		RETURN;
	END IF;
	V_XMLDOC := XMLTYPE(I_FIELD_DATA);
	V_FORM_TYPE := I_FORM_TYPE;

	IF IO_ID IS NOT NULL AND IO_ID > 0 THEN
		V_ID := IO_ID;
	ELSE
		--DBMS_OUTPUT.PUT_LINE('Attempt to find record using PROCID: ' || TO_CHAR(I_PROCID));
		-- if existing record is found using procid, use that id
		IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
			BEGIN
				SELECT ID INTO V_ID FROM TBL_FORM_DTL WHERE PROCID = I_PROCID;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_ID := -1;
			END;
		END IF;

		--DBMS_OUTPUT.PUT_LINE('No record found for PROCID: ' || TO_CHAR(I_PROCID));

		IO_ID := V_ID;
	END IF;

	--DBMS_OUTPUT.PUT_LINE('ID to be used is determined: ' || TO_CHAR(V_ID));

	BEGIN
		SELECT COUNT(*) INTO V_REC_CNT FROM TBL_FORM_DTL WHERE ID = V_ID;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			V_REC_CNT := -1;
	END;

	-- Make sure the existing form data xml is not wiped out by erroneous input
	-- Compare the required field value from the previous form data
	-- with the new one.  If the previous one is not empty but the new one
	-- is empty, then, ignore the update and exit. 
	IF V_REC_CNT > 0 THEN
		
		IF V_FORM_TYPE = 'CMSSTRATCON' THEN
			V_REQ_FORM_FIELD_XPATH := '/DOCUMENT/POSITION/POS_TITLE/text()';
		ELSIF V_FORM_TYPE = 'CMSCLSF' THEN
			V_REQ_FORM_FIELD_XPATH := '/DOCUMENT/GENERAL/CS_TITLE/text()';
		ELSIF V_FORM_TYPE = 'CMSELIGQUAL' THEN
			V_REQ_FORM_FIELD_XPATH := '/DOCUMENT/POSITION/POS_TITLE/text()';
		ELSE
			V_REQ_FORM_FIELD_XPATH := '/INVALIDDOC';
		END IF;
		BEGIN
			SELECT 
				XMLQUERY(V_REQ_FORM_FIELD_XPATH PASSING FIELD_DATA RETURNING CONTENT).GETSTRINGVAL()
				, XMLQUERY(V_REQ_FORM_FIELD_XPATH PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL()
			INTO 
				V_REQ_FORM_FIELD_PREV 
				, V_REQ_FORM_FIELD
			FROM TBL_FORM_DTL 
			WHERE ID = V_ID;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_REQ_FORM_FIELD_PREV := NULL;
				V_REQ_FORM_FIELD := NULL;
				SP_ERROR_LOG();
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_REQ_FORM_FIELD_PREV  = ' || V_REQ_FORM_FIELD_PREV);
		--DBMS_OUTPUT.PUT_LINE('    V_REQ_FORM_FIELD       = ' || V_REQ_FORM_FIELD);
		IF (V_REQ_FORM_FIELD_PREV IS NOT NULL AND LENGTH(V_REQ_FORM_FIELD_PREV) > 0) 
			AND (V_REQ_FORM_FIELD IS NULL OR LENGTH(V_REQ_FORM_FIELD) <= 0)
		THEN
			RETURN;
		END IF;
	END IF;

	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		V_PROCID := I_PROCID;
	ELSE
		V_PROCID := 0;
	END IF;

	IF I_ACTSEQ IS NOT NULL AND I_ACTSEQ > 0 THEN
		V_ACTSEQ := I_ACTSEQ;
	ELSE
		V_ACTSEQ := 0;
	END IF;

	IF I_WITEMSEQ IS NOT NULL AND I_WITEMSEQ > 0 THEN
		V_WITEMSEQ := I_WITEMSEQ;
	ELSE
		V_WITEMSEQ := 0;
	END IF;

	V_USER := I_USER;

	--DBMS_OUTPUT.PUT_LINE('Inspected existence of same record.');
	--DBMS_OUTPUT.PUT_LINE('    V_ID       = ' || TO_CHAR(V_ID));
	--DBMS_OUTPUT.PUT_LINE('    V_PROCID   = ' || TO_CHAR(V_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    V_ACTSEQ   = ' || TO_CHAR(V_ACTSEQ));
	--DBMS_OUTPUT.PUT_LINE('    V_WITEMSEQ = ' || TO_CHAR(V_WITEMSEQ));
	--DBMS_OUTPUT.PUT_LINE('    V_REC_CNT  = ' || TO_CHAR(V_REC_CNT));

	-- Strategic Consultation specific xml data manipulation before insert/update
	IF V_FORM_TYPE = 'CMSSTRATCON' THEN
		SP_UPDATE_STRATCON_DATA( V_XMLDOC );
	END IF;

	IF V_REC_CNT > 0 THEN
		--DBMS_OUTPUT.PUT_LINE('Record found so that field data will be updated on the same record.');

		UPDATE TBL_FORM_DTL
		SET
			PROCID          = V_PROCID
			, ACTSEQ        = V_ACTSEQ
			, WITEMSEQ      = V_WITEMSEQ
			, FIELD_DATA    = V_XMLDOC
			, MOD_DT        = SYSDATE
			, MOD_USR       = V_USER
		WHERE ID = V_ID
		;

	ELSE
		--DBMS_OUTPUT.PUT_LINE('No record found so that new record will be inserted.');

		INSERT INTO TBL_FORM_DTL
		(
--			ID
--			, PROCID
			PROCID
			, ACTSEQ
			, WITEMSEQ
			, FORM_TYPE
			, FIELD_DATA
			, CRT_DT
			, CRT_USR
		)
		VALUES
		(
--			V_ID
--			, V_PROCID
			V_PROCID
			, V_ACTSEQ
			, V_WITEMSEQ
			, V_FORM_TYPE
			, V_XMLDOC
			, SYSDATE
			, V_USER
		)
		;
	END IF;

	-- Update process variable and transition xml into individual tables
	-- for respective process definition
	IF V_FORM_TYPE = 'CMSSTRATCON' THEN
		SP_UPDATE_PV_STRATCON(V_PROCID, V_XMLDOC);
		SP_UPDATE_STRATCON_TABLE(V_PROCID);
	ELSIF V_FORM_TYPE = 'CMSCLSF' THEN
		SP_UPDATE_PV_CLSF(V_PROCID, V_XMLDOC);
		SP_UPDATE_CLSF_TABLE(V_PROCID);
	ELSIF V_FORM_TYPE = 'CMSELIGQUAL' THEN
		SP_UPDATE_PV_ELIGQUAL(V_PROCID, V_XMLDOC);
		SP_UPDATE_ELIGQUAL_TABLE(V_PROCID);
	END IF;

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_FORM_DATA -------------------');
END;

/







--------------------------------------------------------
--  DDL for Function FN_INIT_ELIGQUAL
--------------------------------------------------------

/**
 * Retrieves the initial form data xml for Eligiblity and Qualification process
 * from the form data xml for the associated parent Strategic Consultation
 * process instance or Classification process instance.
 *
 * @param I_PROCID - Process ID of the parent process.
 *
 * @return XMLTYPE - Form data xml as the initial Classification data.
 */
CREATE OR REPLACE FUNCTION FN_INIT_ELIGQUAL
(
	I_PROCID                    IN NUMBER
)
RETURN XMLTYPE
IS
	V_PARENTPROCID              NUMBER(10);
	V_PARENTPROCNAME            VARCHAR2(100);
	V_PARENT_STRATCON_PROCID    NUMBER(10);
	V_PARENT_CLSF_PROCID        NUMBER(10);
	V_FIELD_DATA_SRC            XMLTYPE;
	V_FIELD_DATA_TRG            XMLTYPE;
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_INIT_ELIGQUAL -------');

	-- get parent procid to pull data from
	BEGIN
		SELECT PARENTPROCID INTO V_PARENTPROCID
		FROM BIZFLOW.PROCS
		WHERE PROCID = I_PROCID;
	EXCEPTION
		WHEN OTHERS THEN
			SP_ERROR_LOG();
			V_PARENTPROCID := NULL;
	END;

	-- if no parent to inherit data from, just return
	IF V_PARENTPROCID IS NULL THEN
		RETURN NULL;
	END IF;

	-- check whether the immediate parent is STRATCON or CLSF
	BEGIN
		SELECT PD.NAME INTO V_PARENTPROCNAME
		FROM BIZFLOW.PROCDEF PD INNER JOIN BIZFLOW.PROCS P ON P.ORGPROCDEFID = PD.ORGPROCDEFID
		WHERE PD.ISFINAL = 'T' AND PD.ENVTYPE = 'O' AND P.PROCID = V_PARENTPROCID;
	EXCEPTION
		WHEN OTHERS THEN
			SP_ERROR_LOG();
			V_PARENTPROCNAME := NULL;
	END;

	-- construct initial Eligiblity and Qualification form data xml
	-- from the originating parent process instance data
	IF V_PARENTPROCNAME = 'Strategic Consultation' THEN
		-- construct ELIGQUAL xml from parent STRATCON
		SELECT
			XMLQUERY(
				'
				<DOCUMENT>
					<GENERAL>
						<ADMIN_CD>{             data($sc/DOCUMENT/GENERAL/SG_ADMIN_CD)}</ADMIN_CD>
						<RT_ID>{                data($sc/DOCUMENT/GENERAL/SG_RT_ID)}</RT_ID>
						<AT_ID>{                data($sc/DOCUMENT/GENERAL/SG_AT_ID)}</AT_ID>
						<VT_ID>{                data($sc/DOCUMENT/GENERAL/SG_VT_ID)}</VT_ID>
						<SAT_ID>{               data($sc/DOCUMENT/GENERAL/SG_SAT_ID)}</SAT_ID>
						<CT_ID>{                data($sc/DOCUMENT/GENERAL/SG_CT_ID)}</CT_ID>
						<SO_ID>{                data($sc/DOCUMENT/GENERAL/SG_SO_ID)}</SO_ID>
						<XO_ID>{                data($sc/DOCUMENT/GENERAL/SG_XO_ID)}</XO_ID>
						<HRL_ID>{               data($sc/DOCUMENT/GENERAL/SG_HRL_ID)}</HRL_ID>
						<SS_ID>{                data($sc/DOCUMENT/GENERAL/SG_SS_ID)}</SS_ID>
						<CS_ID>{                data($sc/DOCUMENT/GENERAL/SG_CS_ID)}</CS_ID>
						<SO_AGREE>{             data($sc/DOCUMENT/GENERAL/SG_SO_AGREE)}</SO_AGREE>
						<OTHER_CERT>{           data($sc/DOCUMENT/GENERAL/SG_OTHER_CERT)}</OTHER_CERT>
					</GENERAL>
					<POSITION>
						<POS_ID>{               data($sc/DOCUMENT/POSITION/POS_ID)}</POS_ID>
						<CNDT_LAST_NM>{         data($sc/DOCUMENT/POSITION/POS_CNDT_LAST_NM)}</CNDT_LAST_NM>
						<CNDT_FIRST_NM>{        data($sc/DOCUMENT/POSITION/POS_CNDT_FIRST_NM)}</CNDT_FIRST_NM>
						<CNDT_MIDDLE_NM>{       data($sc/DOCUMENT/POSITION/POS_CNDT_MIDDLE_NM)}</CNDT_MIDDLE_NM>
						<BGT_APR_OFM>{          data($sc/DOCUMENT/POSITION/POS_BGT_APR_OFM)}</BGT_APR_OFM>
						<SPNSR_ORG_NM>{         data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_NM)}</SPNSR_ORG_NM>
						<SPNSR_ORG_FUND_PC>{    data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_FUND_PC)}</SPNSR_ORG_FUND_PC>
						<JOB_REQ_NUMBER>{       data($sc/DOCUMENT/POSITION/POS_JOB_REQ_NUMBER)}</JOB_REQ_NUMBER>
						<JOB_REQ_CREATE_DT>{    data($sc/DOCUMENT/POSITION/POS_JOB_REQ_CREATE_DT)}</JOB_REQ_CREATE_DT>
						<POS_TITLE>{            data($sc/DOCUMENT/POSITION/POS_TITLE)}</POS_TITLE>
						<PAY_PLAN_ID>{          data($sc/DOCUMENT/POSITION/POS_PAY_PLAN_ID)}</PAY_PLAN_ID>
						<SERIES>{               data($sc/DOCUMENT/POSITION/POS_SERIES)}</SERIES>
						<POS_DESC_NUMBER_1>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_1)}</POS_DESC_NUMBER_1>
						<CLASSIFICATION_DT_1>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_1)}</CLASSIFICATION_DT_1>
						<GRADE_1>{              data($sc/DOCUMENT/POSITION/POS_GRADE_1)}</GRADE_1>
						<POS_DESC_NUMBER_2>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_2)}</POS_DESC_NUMBER_2>
						<CLASSIFICATION_DT_2>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_2)}</CLASSIFICATION_DT_2>
						<GRADE_2>{              data($sc/DOCUMENT/POSITION/POS_GRADE_2)}</GRADE_2>
						<POS_DESC_NUMBER_3>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_3)}</POS_DESC_NUMBER_3>
						<CLASSIFICATION_DT_3>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_3)}</CLASSIFICATION_DT_3>
						<GRADE_3>{              data($sc/DOCUMENT/POSITION/POS_GRADE_3)}</GRADE_3>
						<POS_DESC_NUMBER_4>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_4)}</POS_DESC_NUMBER_4>
						<CLASSIFICATION_DT_4>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_4)}</CLASSIFICATION_DT_4>
						<GRADE_4>{              data($sc/DOCUMENT/POSITION/POS_GRADE_4)}</GRADE_4>
						<POS_DESC_NUMBER_5>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_5)}</POS_DESC_NUMBER_5>
						<CLASSIFICATION_DT_5>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_5)}</CLASSIFICATION_DT_5>
						<GRADE_5>{              data($sc/DOCUMENT/POSITION/POS_GRADE_5)}</GRADE_5>
						<PERFORMANCE_LEVEL>{    data($sc/DOCUMENT/POSITION/POS_PERFORMANCE_LEVEL)}</PERFORMANCE_LEVEL>
						<SUPERVISORY>{          data($sc/DOCUMENT/POSITION/POS_SUPERVISORY)}</SUPERVISORY>
						<MED_OFFICERS_ID>{      data($sc/DOCUMENT/POSITION/POS_MED_OFFICERS_ID)}</MED_OFFICERS_ID>
						<SKILL>{                data($sc/DOCUMENT/POSITION/POS_SKILL)}</SKILL>
						<GRADES_ADVERTISED>{    data($sc/DOCUMENT/POSITION/POS_GRADES_ADVERTISED)}</GRADES_ADVERTISED>
						<LOCATION>{             data($sc/DOCUMENT/POSITION/POS_LOCATION)}</LOCATION>
						<VACANCIES>{            data($sc/DOCUMENT/POSITION/POS_VACANCIES)}</VACANCIES>
						<REPORT_SUPERVISOR>{    data($sc/DOCUMENT/POSITION/POS_REPORT_SUPERVISOR)}</REPORT_SUPERVISOR>
						<CAN>{                  data($sc/DOCUMENT/POSITION/POS_CAN)}</CAN>
						<VICE>{                 data($sc/DOCUMENT/POSITION/POS_VICE)}</VICE>
						<VICE_NAME>{            data($sc/DOCUMENT/POSITION/POS_VICE_NAME)}</VICE_NAME>
						<DAYS_ADVERTISED>{      data($sc/DOCUMENT/POSITION/POS_DAYS_ADVERTISED)}</DAYS_ADVERTISED>
						<TA_ID>{                data($sc/DOCUMENT/POSITION/POS_AT_ID)}</TA_ID>
						<NTE>{                  data($sc/DOCUMENT/POSITION/POS_NTE)}</NTE>
						<WORK_SCHED_ID>{        data($sc/DOCUMENT/POSITION/POS_WORK_SCHED_ID)}</WORK_SCHED_ID>
						<HOURS_PER_WEEK>{       data($sc/DOCUMENT/POSITION/POS_HOURS_PER_WEEK)}</HOURS_PER_WEEK>
						<DUAL_EMPLMT>{          data($sc/DOCUMENT/POSITION/POS_DUAL_EMPLMT)}</DUAL_EMPLMT>
						<SEC_ID>{               data($sc/DOCUMENT/POSITION/POS_SEC_ID)}</SEC_ID>
						<CE_FINANCIAL_DISC>{    data($sc/DOCUMENT/POSITION/POS_CE_FINANCIAL_DISC)}</CE_FINANCIAL_DISC>
						<CE_FINANCIAL_TYPE_ID>{ data($sc/DOCUMENT/POSITION/POS_CE_FINANCIAL_TYPE_ID)}</CE_FINANCIAL_TYPE_ID>
						<CE_PE_PHYSICAL>{       data($sc/DOCUMENT/POSITION/POS_CE_PE_PHYSICAL)}</CE_PE_PHYSICAL>
						<CE_DRUG_TEST>{         data($sc/DOCUMENT/POSITION/POS_CE_DRUG_TEST)}</CE_DRUG_TEST>
						<CE_IMMUN>{             data($sc/DOCUMENT/POSITION/POS_CE_IMMUN)}</CE_IMMUN>
						<CE_TRAVEL>{            data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL)}</CE_TRAVEL>
						<CE_TRAVEL_PER>{        data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL_PER)}</CE_TRAVEL_PER>
						<CE_LIC>{               data($sc/DOCUMENT/POSITION/POS_CE_LIC)}</CE_LIC>
						<CE_LIC_INFO>{          data($sc/DOCUMENT/POSITION/POS_CE_LIC_INFO)}</CE_LIC_INFO>
						<REMARKS>{              data($sc/DOCUMENT/POSITION/POS_REMARKS)}</REMARKS>
						<PROC_REQ_TYPE>{        data($sc/DOCUMENT/POSITION/POS_PROC_REQ_TYPE)}</PROC_REQ_TYPE>
						<RECRUIT_OFFICE_ID>{    data($sc/DOCUMENT/POSITION/POS_RECRUIT_OFFICE_ID)}</RECRUIT_OFFICE_ID>
						<REQ_ID>{               data($sc/DOCUMENT/POSITION/POS_REQ_ID)}</REQ_ID>
						<REQ_CREATE_NOTIFY_DT>{ data($sc/DOCUMENT/POSITION/POS_REQ_CREATE_NOTIFY_DT)}</REQ_CREATE_NOTIFY_DT>
						<ASSOC_DESCR_NUMBERS>{  data($sc/DOCUMENT/POSITION/POS_ASSOC_DESCR_NUMBERS)}</ASSOC_DESCR_NUMBERS>
						<PROMOTE_POTENTIAL>{    data($sc/DOCUMENT/POSITION/POS_PROMOTE_POTENTIAL)}</PROMOTE_POTENTIAL>
						<VICE_EMPL_ID>{         data($sc/DOCUMENT/POSITION/POS_VICE_EMPL_ID)}</VICE_EMPL_ID>
						<SR_ID>{                data($sc/DOCUMENT/POSITION/POS_SR_ID)}</SR_ID>
						<GR_ID>{                data($sc/DOCUMENT/POSITION/POS_GR_ID)}</GR_ID>
						<STATUS_ID>{            data($sc/DOCUMENT/POSITION/POS_STATUS_ID)}</STATUS_ID>
						<SC_REQUESTED>{         data($sc/DOCUMENT/POSITION/POS_SC_REQUESTED)}</SC_REQUESTED>
						<SG_ID>{                data($sc/DOCUMENT/POSITION/POS_SG_ID)}</SG_ID>
						<PD_ID>{                data($sc/DOCUMENT/POSITION/POS_PD_ID)}</PD_ID>
						<GRADE_ADVERTISED>
							<GA_1>{ data($sc/DOCUMENT/POSITION/POS_GA_1)}</GA_1>
							<GA_2>{ data($sc/DOCUMENT/POSITION/POS_GA_2)}</GA_2>
							<GA_3>{ data($sc/DOCUMENT/POSITION/POS_GA_3)}</GA_3>
							<GA_4>{ data($sc/DOCUMENT/POSITION/POS_GA_4)}</GA_4>
							<GA_5>{ data($sc/DOCUMENT/POSITION/POS_GA_5)}</GA_5>
							<GA_6>{ data($sc/DOCUMENT/POSITION/POS_GA_6)}</GA_6>
							<GA_7>{ data($sc/DOCUMENT/POSITION/POS_GA_7)}</GA_7>
							<GA_8>{ data($sc/DOCUMENT/POSITION/POS_GA_8)}</GA_8>
							<GA_9>{ data($sc/DOCUMENT/POSITION/POS_GA_9)}</GA_9>
							<GA_10>{data($sc/DOCUMENT/POSITION/POS_GA_10)}</GA_10>
							<GA_11>{data($sc/DOCUMENT/POSITION/POS_GA_11)}</GA_11>
							<GA_12>{data($sc/DOCUMENT/POSITION/POS_GA_12)}</GA_12>
							<GA_13>{data($sc/DOCUMENT/POSITION/POS_GA_13)}</GA_13>
							<GA_14>{data($sc/DOCUMENT/POSITION/POS_GA_14)}</GA_14>
							<GA_15>{data($sc/DOCUMENT/POSITION/POS_GA_15)}</GA_15>
						</GRADE_ADVERTISED>
					</POSITION>
				</DOCUMENT>
				'
				PASSING FD.FIELD_DATA AS "sc"
				RETURNING CONTENT
			) INTO V_FIELD_DATA_TRG
		FROM
			TBL_FORM_DTL FD
		WHERE
			1=1
			AND FD.PROCID = V_PARENTPROCID
			AND XMLEXISTS('data($sc/DOCUMENT/POSITION)' PASSING FD.FIELD_DATA AS "sc")
		;
	ELSIF V_PARENTPROCNAME = 'Classification' THEN
		V_PARENT_CLSF_PROCID := V_PARENTPROCID;
		-- get procid for Strategic Consultation process which is parent of
		-- Classification process to pull data from
		BEGIN
			SELECT PARENTPROCID INTO V_PARENT_STRATCON_PROCID
			FROM BIZFLOW.PROCS
			WHERE PROCID = V_PARENT_CLSF_PROCID;
		EXCEPTION
			WHEN OTHERS THEN
				SP_ERROR_LOG();
				V_PARENT_STRATCON_PROCID := NULL;
		END;

		-- construct ELIGQUAL xml from grandparent STRATCON and parent CLSF
		SELECT
			XMLQUERY(
				'
					<DOCUMENT>
						<GENERAL>
							<ADMIN_CD>{             data($cl/DOCUMENT/GENERAL/CS_ADMIN_CD)}</ADMIN_CD>
							<RT_ID>{                data($sc/DOCUMENT/GENERAL/SG_RT_ID)}</RT_ID>
							<AT_ID>{                data($sc/DOCUMENT/GENERAL/SG_AT_ID)}</AT_ID>
							<VT_ID>{                data($sc/DOCUMENT/GENERAL/SG_VT_ID)}</VT_ID>
							<SAT_ID>{               data($sc/DOCUMENT/GENERAL/SG_SAT_ID)}</SAT_ID>
							<CT_ID>{                data($sc/DOCUMENT/GENERAL/SG_CT_ID)}</CT_ID>
							<SO_ID>{                data($sc/DOCUMENT/GENERAL/SG_SO_ID)}</SO_ID>
							<XO_ID>{                data($sc/DOCUMENT/GENERAL/SG_XO_ID)}</XO_ID>
							<HRL_ID>{               data($sc/DOCUMENT/GENERAL/SG_HRL_ID)}</HRL_ID>
							<SS_ID>{                data($sc/DOCUMENT/GENERAL/SG_SS_ID)}</SS_ID>
							<CS_ID>{                data($sc/DOCUMENT/GENERAL/SG_CS_ID)}</CS_ID>
							<SO_AGREE>{             data($sc/DOCUMENT/GENERAL/SG_SO_AGREE)}</SO_AGREE>
							<OTHER_CERT>{           data($sc/DOCUMENT/GENERAL/SG_OTHER_CERT)}</OTHER_CERT>
						</GENERAL>
						<POSITION>
							<POS_ID>{               data($sc/DOCUMENT/POSITION/POS_ID)}</POS_ID>
							<CNDT_LAST_NM>{         data($sc/DOCUMENT/POSITION/POS_CNDT_LAST_NM)}</CNDT_LAST_NM>
							<CNDT_FIRST_NM>{        data($sc/DOCUMENT/POSITION/POS_CNDT_FIRST_NM)}</CNDT_FIRST_NM>
							<CNDT_MIDDLE_NM>{       data($sc/DOCUMENT/POSITION/POS_CNDT_MIDDLE_NM)}</CNDT_MIDDLE_NM>
							<BGT_APR_OFM>{          data($sc/DOCUMENT/POSITION/POS_BGT_APR_OFM)}</BGT_APR_OFM>
							<SPNSR_ORG_NM>{         data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_NM)}</SPNSR_ORG_NM>
							<SPNSR_ORG_FUND_PC>{    data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_FUND_PC)}</SPNSR_ORG_FUND_PC>
							<JOB_REQ_NUMBER>{       data($sc/DOCUMENT/POSITION/POS_JOB_REQ_NUMBER)}</JOB_REQ_NUMBER>
							<JOB_REQ_CREATE_DT>{    data($sc/DOCUMENT/POSITION/POS_JOB_REQ_CREATE_DT)}</JOB_REQ_CREATE_DT>

							<POS_TITLE>{            data($cl/DOCUMENT/GENERAL/CS_TITLE)}</POS_TITLE>
							<PAY_PLAN_ID>{          data($cl/DOCUMENT/GENERAL/CS_PAY_PLAN_ID)}</PAY_PLAN_ID>
							<SERIES>{               data($cl/DOCUMENT/GENERAL/CS_SR_ID)}</SERIES>
							<POS_DESC_NUMBER_1>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_1)}</POS_DESC_NUMBER_1>
							<CLASSIFICATION_DT_1>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_1)}</CLASSIFICATION_DT_1>
							<GRADE_1>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_1)}</GRADE_1>
							<POS_DESC_NUMBER_2>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_2)}</POS_DESC_NUMBER_2>
							<CLASSIFICATION_DT_2>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_2)}</CLASSIFICATION_DT_2>
							<GRADE_2>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_2)}</GRADE_2>
							<POS_DESC_NUMBER_3>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_3)}</POS_DESC_NUMBER_3>
							<CLASSIFICATION_DT_3>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_3)}</CLASSIFICATION_DT_3>
							<GRADE_3>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_3)}</GRADE_3>
							<POS_DESC_NUMBER_4>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_4)}</POS_DESC_NUMBER_4>
							<CLASSIFICATION_DT_4>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_4)}</CLASSIFICATION_DT_4>
							<GRADE_4>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_4)}</GRADE_4>
							<POS_DESC_NUMBER_5>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_5)}</POS_DESC_NUMBER_5>
							<CLASSIFICATION_DT_5>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_5)}</CLASSIFICATION_DT_5>
							<GRADE_5>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_5)}</GRADE_5>
							<PERFORMANCE_LEVEL>{    data($cl/DOCUMENT/GENERAL/CS_PERFORMANCE_LEVEL)}</PERFORMANCE_LEVEL>
							<SUPERVISORY>{          data($cl/DOCUMENT/GENERAL/CS_SUPERVISORY)}</SUPERVISORY>

							<MED_OFFICERS_ID>{      $moid }</MED_OFFICERS_ID>

							<SKILL>{                data($sc/DOCUMENT/POSITION/POS_SKILL)}</SKILL>
							<GRADES_ADVERTISED>{    data($sc/DOCUMENT/POSITION/POS_GRADES_ADVERTISED)}</GRADES_ADVERTISED>
							<LOCATION>{             data($sc/DOCUMENT/POSITION/POS_LOCATION)}</LOCATION>
							<VACANCIES>{            data($sc/DOCUMENT/POSITION/POS_VACANCIES)}</VACANCIES>
							<REPORT_SUPERVISOR>{    data($sc/DOCUMENT/POSITION/POS_REPORT_SUPERVISOR)}</REPORT_SUPERVISOR>
							<CAN>{                  data($sc/DOCUMENT/POSITION/POS_CAN)}</CAN>
							<VICE>{                 data($sc/DOCUMENT/POSITION/POS_VICE)}</VICE>
							<VICE_NAME>{            data($sc/DOCUMENT/POSITION/POS_VICE_NAME)}</VICE_NAME>
							<DAYS_ADVERTISED>{      data($sc/DOCUMENT/POSITION/POS_DAYS_ADVERTISED)}</DAYS_ADVERTISED>
							<TA_ID>{                data($sc/DOCUMENT/POSITION/POS_AT_ID)}</TA_ID>
							<NTE>{                  data($sc/DOCUMENT/POSITION/POS_NTE)}</NTE>
							<WORK_SCHED_ID>{        data($sc/DOCUMENT/POSITION/POS_WORK_SCHED_ID)}</WORK_SCHED_ID>
							<HOURS_PER_WEEK>{       data($sc/DOCUMENT/POSITION/POS_HOURS_PER_WEEK)}</HOURS_PER_WEEK>
							<DUAL_EMPLMT>{          data($sc/DOCUMENT/POSITION/POS_DUAL_EMPLMT)}</DUAL_EMPLMT>

							<SEC_ID>{               data($cl/DOCUMENT/CLASSIFICATION_CODE/CS_SEC_ID)}</SEC_ID>
							<CE_FINANCIAL_DISC>{    if (not(data($cl/DOCUMENT/CLASSIFICATION_CODE/CS_FIN_STMT_REQ_ID) = "")) then "true" else "false" }</CE_FINANCIAL_DISC>
							<CE_FINANCIAL_TYPE_ID>{ data($cl/DOCUMENT/CLASSIFICATION_CODE/CS_FIN_STMT_REQ_ID)}</CE_FINANCIAL_TYPE_ID>

							<CE_PE_PHYSICAL>{       data($sc/DOCUMENT/POSITION/POS_CE_PE_PHYSICAL)}</CE_PE_PHYSICAL>
							<CE_DRUG_TEST>{         data($sc/DOCUMENT/POSITION/POS_CE_DRUG_TEST)}</CE_DRUG_TEST>
							<CE_IMMUN>{             data($sc/DOCUMENT/POSITION/POS_CE_IMMUN)}</CE_IMMUN>
							<CE_TRAVEL>{            data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL)}</CE_TRAVEL>
							<CE_TRAVEL_PER>{        data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL_PER)}</CE_TRAVEL_PER>
							<CE_LIC>{               data($sc/DOCUMENT/POSITION/POS_CE_LIC)}</CE_LIC>
							<CE_LIC_INFO>{          data($sc/DOCUMENT/POSITION/POS_CE_LIC_INFO)}</CE_LIC_INFO>
							<REMARKS>{              data($sc/DOCUMENT/POSITION/POS_REMARKS)}</REMARKS>
							<PROC_REQ_TYPE>{        data($sc/DOCUMENT/POSITION/POS_PROC_REQ_TYPE)}</PROC_REQ_TYPE>
							<RECRUIT_OFFICE_ID>{    data($sc/DOCUMENT/POSITION/POS_RECRUIT_OFFICE_ID)}</RECRUIT_OFFICE_ID>
							<REQ_ID>{               data($sc/DOCUMENT/POSITION/POS_REQ_ID)}</REQ_ID>
							<REQ_CREATE_NOTIFY_DT>{ data($sc/DOCUMENT/POSITION/POS_REQ_CREATE_NOTIFY_DT)}</REQ_CREATE_NOTIFY_DT>
							<ASSOC_DESCR_NUMBERS>{  data($sc/DOCUMENT/POSITION/POS_ASSOC_DESCR_NUMBERS)}</ASSOC_DESCR_NUMBERS>
							<PROMOTE_POTENTIAL>{    data($sc/DOCUMENT/POSITION/POS_PROMOTE_POTENTIAL)}</PROMOTE_POTENTIAL>
							<VICE_EMPL_ID>{         data($sc/DOCUMENT/POSITION/POS_VICE_EMPL_ID)}</VICE_EMPL_ID>
							<SR_ID>{                data($sc/DOCUMENT/POSITION/POS_SR_ID)}</SR_ID>
							<GR_ID>{                data($sc/DOCUMENT/POSITION/POS_GR_ID)}</GR_ID>
							<STATUS_ID>{            data($sc/DOCUMENT/POSITION/POS_STATUS_ID)}</STATUS_ID>
							<SC_REQUESTED>{         data($sc/DOCUMENT/POSITION/POS_SC_REQUESTED)}</SC_REQUESTED>
							<SG_ID>{                data($sc/DOCUMENT/POSITION/POS_SG_ID)}</SG_ID>
							<PD_ID>{                data($sc/DOCUMENT/POSITION/POS_PD_ID)}</PD_ID>
							<GRADE_ADVERTISED>
								<GA_1>{ data($sc/DOCUMENT/POSITION/POS_GA_1)}</GA_1>
								<GA_2>{ data($sc/DOCUMENT/POSITION/POS_GA_2)}</GA_2>
								<GA_3>{ data($sc/DOCUMENT/POSITION/POS_GA_3)}</GA_3>
								<GA_4>{ data($sc/DOCUMENT/POSITION/POS_GA_4)}</GA_4>
								<GA_5>{ data($sc/DOCUMENT/POSITION/POS_GA_5)}</GA_5>
								<GA_6>{ data($sc/DOCUMENT/POSITION/POS_GA_6)}</GA_6>
								<GA_7>{ data($sc/DOCUMENT/POSITION/POS_GA_7)}</GA_7>
								<GA_8>{ data($sc/DOCUMENT/POSITION/POS_GA_8)}</GA_8>
								<GA_9>{ data($sc/DOCUMENT/POSITION/POS_GA_9)}</GA_9>
								<GA_10>{data($sc/DOCUMENT/POSITION/POS_GA_10)}</GA_10>
								<GA_11>{data($sc/DOCUMENT/POSITION/POS_GA_11)}</GA_11>
								<GA_12>{data($sc/DOCUMENT/POSITION/POS_GA_12)}</GA_12>
								<GA_13>{data($sc/DOCUMENT/POSITION/POS_GA_13)}</GA_13>
								<GA_14>{data($sc/DOCUMENT/POSITION/POS_GA_14)}</GA_14>
								<GA_15>{data($sc/DOCUMENT/POSITION/POS_GA_15)}</GA_15>
							</GRADE_ADVERTISED>
						</POSITION>
					</DOCUMENT>
				'
				PASSING FDSC.FIELD_DATA AS "sc", FDCL.FIELD_DATA AS "cl", LUMO.MED_OFFICERS_ID AS "moid"
				RETURNING CONTENT
			) INTO V_FIELD_DATA_TRG
		FROM
			TBL_FORM_DTL FDSC
			, TBL_FORM_DTL FDCL
			, XMLTABLE('/DOCUMENT/GENERAL/POS_INFORMATION' PASSING FDCL.FIELD_DATA
				COLUMNS
					PD_PCA                 VARCHAR2(10)   PATH 'PD_PCA'
					, PD_PDP               VARCHAR2(10)   PATH 'PD_PDP'
			) MO
			LEFT OUTER JOIN (
				SELECT
					TBL_ID AS MED_OFFICERS_ID
					, TBL_LABEL AS MED_OFFICERS_DSCR
					, CASE WHEN TBL_LABEL LIKE '%(PCA)%' THEN 'true' ELSE 'false' END AS PD_PCA
					, CASE WHEN TBL_LABEL LIKE '%(PDP)%' THEN 'true' ELSE 'false' END AS PD_PDP
				FROM TBL_LOOKUP
				WHERE TBL_LTYPE = 'MedicalOfficer'
			) LUMO ON LUMO.PD_PCA = MO.PD_PCA AND LUMO.PD_PDP = MO.PD_PDP
		WHERE
			1=1
			AND FDSC.FORM_TYPE = 'CMSSTRATCON'
			AND FDSC.PROCID = V_PARENT_STRATCON_PROCID
			AND FDCL.FORM_TYPE = 'CMSCLSF'
			AND FDCL.PROCID = V_PARENT_CLSF_PROCID
		;
	ELSE
		RETURN NULL;  -- no parent name --> something went wrong
	END IF;


	--DBMS_OUTPUT.PUT_LINE('    V_FIELD_DATA_TRG = ' || V_FIELD_DATA_TRG.GETCLOBVAL());
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_INIT_ELIGQUAL -------');
	RETURN V_FIELD_DATA_TRG;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing Eligiblity and Qualification initialization -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
		RETURN NULL;
END;

/








/**
 * Updates initial Eligiblity and Qualification process data.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_INIT_ELIGQUAL
(

	I_PROCID               IN  NUMBER
)
IS
	V_ID                       NUMBER(20);
	V_XMLCLOB                  CLOB;
	V_RLVNTDATANAME            VARCHAR2(100);
	V_VALUE                    NVARCHAR2(2000);
	V_VALUE_LOOKUP             NVARCHAR2(2000);
	V_XMLDOC                   XMLTYPE;
	V_XMLVALUE                 XMLTYPE;
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: SP_UPDATE_INIT_ELIGQUAL -------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID = ' || TO_CHAR(I_PROCID));

	SELECT FN_INIT_ELIGQUAL(I_PROCID) INTO V_XMLDOC FROM DUAL;
	--SELECT V_XMLDOC.GETCLOBVAL() INTO V_XMLCLOB FROM DUAL;
	--DBMS_OUTPUT.PUT_LINE('    V_XMLCLOB = ' || V_XMLCLOB);

	-- set PV that should be initialized and stays the same until proc completion
	V_XMLVALUE := V_XMLDOC.EXTRACT('/DOCUMENT/GENERAL/AT_ID/text()');
	IF V_XMLVALUE IS NOT NULL THEN
		V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE(AT_ID) = ' || V_VALUE);

		---------------------------------
		-- replace with lookup value
		---------------------------------
		BEGIN
			SELECT TBL_LABEL INTO V_VALUE_LOOKUP
			FROM TBL_LOOKUP
			WHERE TBL_ID = TO_NUMBER(V_VALUE);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_VALUE_LOOKUP := NULL;
			WHEN OTHERS THEN
				V_VALUE_LOOKUP := NULL;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE_LOOKUP(AT_ID) = ' || V_VALUE_LOOKUP);

		IF V_VALUE_LOOKUP IN ('Expert/Consultant', '30% or more disabled veterans', 'Veteran Recruitment Appointment (VRA)') THEN
			V_VALUE := 'Yes';  -- set final PV value
		ELSIF V_VALUE_LOOKUP = 'Schedule A' THEN
			V_XMLVALUE := V_XMLDOC.EXTRACT('/DOCUMENT/GENERAL/SAT_ID/text()');
			IF V_XMLVALUE IS NOT NULL THEN
				V_VALUE := V_XMLVALUE.GETSTRINGVAL();
				--DBMS_OUTPUT.PUT_LINE('    V_VALUE(SAT_ID) = ' || V_VALUE);

				---------------------------------
				-- replace with lookup value
				---------------------------------
				BEGIN
					SELECT TBL_LABEL INTO V_VALUE_LOOKUP
					FROM TBL_LOOKUP
					WHERE TBL_ID = TO_NUMBER(V_VALUE);
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						V_VALUE_LOOKUP := NULL;
					WHEN OTHERS THEN
						V_VALUE_LOOKUP := NULL;
				END;
				--DBMS_OUTPUT.PUT_LINE('    V_VALUE_LOOKUP(SAT_ID) = ' || V_VALUE_LOOKUP);

				IF V_VALUE_LOOKUP = 'Disability (U)' THEN
					V_VALUE := 'Yes';  -- set final PV value
				END IF;
			END IF;
		END IF;

		IF V_VALUE IS NULL OR V_VALUE <> 'Yes' THEN
			V_VALUE := 'No';  -- set final PV value
		END IF;
		V_RLVNTDATANAME := 'selectionRequired';
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
	END IF;


	SP_UPDATE_FORM_DATA(V_ID, 'CMSELIGQUAL'
		, V_XMLDOC.GETCLOBVAL()
		, 'SYSTEM'
		, I_PROCID, 0, 0
	);

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_INIT_ELIGQUAL -------------------');
END;
/







