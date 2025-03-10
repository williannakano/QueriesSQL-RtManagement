--Consulta 6 - Agenda Elekta: Captura informações de agendamento do AL2 e AL3

WITH BS_TREATMENT AS (
	SELECT DISTINCT
			 CAST(TT.CREATE_DTTM AS DATE) AS DT_TRATAMENTO
			,ID.IDA			AS ID_PACIENT_HCA
			,ST1.USER_NAME AS USER_REGISTRO
			,ST2.USER_NAME AS USER_ULTIMA_EDICAO
			,IIF(MACHINE_ID_STAFF_ID = 96,'VERSA', 'PRECISE') AS LINAC
	FROM
						MOSAIQ.DBO.TRACKTREATMENT	AS TT  (NOLOCK)
			INNER JOIN  MOSAIQ.DBO.PATIENT				AS PT  (NOLOCK) ON PT.PAT_ID1 = TT.PAT_ID1
			INNER JOIN  MOSAIQ.DBO.IDENT				AS ID  (NOLOCK) ON ID.PAT_ID1 = PT.PAT_ID1
			LEFT JOIN	MOSAIQ.DBO.STAFF			AS ST1 (NOLOCK) ON TT.CREATE_ID = ST1. STAFF_ID
			LEFT JOIN	MOSAIQ.DBO.STAFF			AS ST2 (NOLOCK) ON TT.EDIT_ID = ST2. STAFF_ID
	WHERE
				1=1
			AND TT.WasQAMode = 0
			AND CAST(TT.CREATE_DTTM AS DATE) >= '2023-01-01'
)
SELECT
		 DT_TRATAMENTO
		,ID_PACIENT_HCA
		,USER_REGISTRO
		,USER_ULTIMA_EDICAO
		,LINAC
		,ROW_NUMBER() OVER (PARTITION BY ID_PACIENT_HCA	ORDER BY DT_TRATAMENTO ASC) AS ORD
FROM
		BS_TREATMENT
WHERE 
			1=1
