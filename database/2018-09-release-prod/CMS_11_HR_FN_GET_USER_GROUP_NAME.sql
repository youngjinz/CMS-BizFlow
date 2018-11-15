-- CNS_HR_DB_UPD_09_create_core_program.sql

/**
 * Gets current user group name
 *
 * @param I_KEY - a user's group key name
 *
 * @return a user group name
 */
CREATE OR REPLACE FUNCTION FN_GET_USER_GROUP_NAME
  (
    I_KEY IN VARCHAR2
  )
  RETURN VARCHAR2
IS
  L_NAME VARCHAR2(100);

  BEGIN

    SELECT NAME INTO L_NAME FROM UG_MAPPING WHERE KEY = I_KEY;

    RETURN L_NAME;
  END;
/

-- CMS_HR_DB_UPD_10_permission_core.sql
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_USER_GROUP_NAME TO BIZFLOW;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_USER_GROUP_NAME TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_USER_GROUP_NAME TO HHS_CMS_HR_DEV_ROLE;