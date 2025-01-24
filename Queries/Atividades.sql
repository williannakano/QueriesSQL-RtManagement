with
BS_ATIVIDADES AS (
SELECT
	*
FROM
	(
	SELECT
		 AT.DimPatientID
		,IIF(LEFT(AC.ActivityCategoryCode,2)='00','Tratamento', 'Planning') AS TIP_DADO
		,AC.ActivityCategoryCode	AS RECURSO_CATEGORIA
		,CASE 
			WHEN AC.ActivityCode = 'Conferir ficha' THEN 'Duplo Check'	
				WHEN AC.ActivityCode = 'Preparar tudo' THEN 'Montar ficha'	
					WHEN AC.ActivityCode = 'Planejamento URG' THEN 'Planejamento'
						WHEN AC.ActivityCode = 'Aprovar plano URG' THEN 'Aprovar plano'
							WHEN AC.ActivityCode = 'Contorno URG' THEN 'Contornar Estruturas'
				ELSE AC.ActivityCode
			END AS NOM_ATIVIDADE_2
		,CASE 
			WHEN AC.ActivityCode = 'Conferir ficha' THEN 'Duplo Check'	
				WHEN AC.ActivityCode = 'Preparar tudo' THEN 'Montar ficha'	
				ELSE AC.ActivityCode
			END AS NOM_ATIVIDADE
		,US1.UserId					AS ID_RECURSO_ATENDIMENTO
		,US1.DisplayName				AS NOM_RECURSO
		,AC.ctrActivityCategorySer
		,AC.ctrActivitySer
		,AT.AppointmentStatus				AS STATUS
		,CASE 
			WHEN AC.ActivityCode LIKE '%URG%' THEN 'URGENTE'
				WHEN AC.ActivityCode LIKE '%2D%' THEN 'ELETRONS'
					ELSE 'CONVENCIONAL'
			END AS AUX_TIP_FLUXO
		,AppointmentDateTime 				AS data_agendamento_atv
		,ScheduledEndTime 				AS data_vencimento_agendamento
		,AT.ActivityStartDateTime 			AS DATA_INI_ATIVIDADE
		,AT.ActivityEndDateTime 			AS DATA_FIM_ATIVIDADE
		,ROW_NUMBER() OVER (PARTITION BY AT.DimPatientID, (
								CASE 
								WHEN AC.ActivityCode = 'Conferir ficha' THEN 'Duplo Check'	
								WHEN AC.ActivityCode = 'Preparar tudo' THEN 'Montar ficha'	
								WHEN AC.ActivityCode = 'Planejamento URG' THEN 'Planejamento'
								WHEN AC.ActivityCode = 'Aprovar plano URG' THEN 'Aprovar plano'
								WHEN AC.ActivityCode = 'Contorno URG' THEN 'Contornar Estruturas'
								ELSE AC.ActivityCode
								END) ORDER BY ScheduledEndTime ASC) AS NUM_FLUXO
		,CASE 
			WHEN AC.ActivityCode = 'Solicitacao TC' THEN 1
				ELSE AT.ActivityOwnerFlag
			END 					AS FLG_1
	from
			   [variandw].[DWH].[DimActivityTransaction]	AS AT  (NOLOCK)
		INNER JOIN [variandw].[DWH].[DimActivity]		AS AC  (NOLOCK) ON AC.DimActivityID = AT.DimActivityID
		LEFT  JOIN [variandw].[DWH].[DimUser]			AS US1 (NOLOCK) ON US1.DimResourceID = AT.DimResourceID
	where
			1=1
		AND AppointmentResourceStatus NOT IN ('Deleted')
		AND AppointmentStatus NOT IN ('Cancelled')
		AND AT.DimResourceID <> 0 
		AND CAST(AT.ActivityEndDateTime AS DATE) >= '2023-01-01'
	) AS BS
),
BS_ELETRONS_URG AS (
		SELECT DISTINCT 
			 DimPatientID
			,NUM_FLUXO
			,AUX_TIP_FLUXO
		FROM
			BS_ATIVIDADES
		WHERE
			    AUX_TIP_FLUXO IN ('URGENTE','ELETRONS')
			AND TIP_DADO = 'Planning'
		),
BS_PRIORIDADES AS (
		SELECT DISTINCT 
			 DimPatientID
			,NUM_FLUXO
			,NOM_ATIVIDADE AS PRIORIDADE
		FROM
			BS_ATIVIDADES
		WHERE
			    NOM_ATIVIDADE IN ('P1','P2', 'P3')
			AND TIP_DADO = 'Planning'
		)


SELECT
	 DimPatientID
	,TIP_DADO
	,RECURSO_CATEGORIA
	,NOM_ATIVIDADE
	,ID_RECURSO_ATENDIMENTO
	,NOM_RECURSO
	,STATUS
	,data_agendamento_atv
	,data_vencimento_agendamento
	,DATA_INI_ATIVIDADE
	,DATA_FIM_ATIVIDADE
	,NUM_FLUXO
	,TIP_FLUXO
	,ROW_NUMBER() OVER (PARTITION BY DimPatientID, NUM_FLUXO, TIP_FLUXO ORDER BY data_vencimento_agendamento ASC) ORDEM_ATIVIDADES
FROM
	(
		SELECT
			TB1.*
			,ISNULL(ISNULL(TB2.AUX_TIP_FLUXO,TB3.PRIORIDADE),'FLUXO ANTIGO') AS TIP_FLUXO
		FROM
				  BS_ATIVIDADES		AS TB1
			LEFT JOIN BS_ELETRONS_URG	AS TB2 ON TB1.DimPatientID = TB2. DimPatientID AND TB1.NUM_FLUXO = TB2.NUM_FLUXO
			LEFT JOIN BS_PRIORIDADES	AS TB3 ON TB1.DimPatientID = TB3. DimPatientID AND TB1.NUM_FLUXO = TB3.NUM_FLUXO
		WHERE
			    NOM_ATIVIDADE NOT IN ('P1','P2', 'P3')
			AND TB1.FLG_1 = 1
	)AS BS_FINAL
WHERE
	    1=1
	AND TIP_DADO = 'Planning'
