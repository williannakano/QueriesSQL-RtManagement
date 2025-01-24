with
BS_ATIVIDADES AS (
		SELECT
				*
		FROM
				(
						select
								
								 AT.DimPatientID
								,AC.ActivityCategoryCode	AS RECURSO_CATEGORIA
								,AC.ActivityCode			AS NOM_ATIVIDADE
								,US1.UserId					AS ID_RECURSO_ATENDIMENTO
								,US1.DisplayName			AS NOM_RECURSO
								,AT.AppointmentStatus		AS STATUS
								,AppointmentDateTime		AS data_agendamento_atv
								,ScheduledEndTime			AS data_vencimento_agendamento
								,AT.ActivityStartDateTime	AS DATA_INI_ATIVIDADE
								,AT.ActivityEndDateTime		AS DATA_FIM_ATIVIDADE
								,ROW_NUMBER() OVER (PARTITION BY AT.DimPatientID ORDER BY ScheduledEndTime ASC) AS Ordem_Tratamento
						from
											[variandw].[DWH].[DimActivityTransaction]	AS AT (NOLOCK)
								INNER JOIN	[variandw].[DWH].[DimActivity]				AS AC (NOLOCK) ON AC.DimActivityID = AT.DimActivityID
								LEFT  JOIN	[variandw].[DWH].[DimUser]					AS US1 (NOLOCK) ON US1.DimResourceID = AT.DimResourceID
						where
									1=1
								AND AppointmentResourceStatus NOT IN ('Deleted')
								AND AppointmentStatus NOT IN ('Cancelled')
								AND AT.DimResourceID <> 0 
								AND LEFT(AC.ActivityCategoryCode,2)='00'
								AND cast(AT.ActivityEndDateTime AS date) >= '2023-01-01'
				) AS BS
	)

SELECT
		DimPatientID
		,RECURSO_CATEGORIA
		,NOM_ATIVIDADE
		,STATUS
		,data_agendamento_atv
		,data_vencimento_agendamento
		,DATA_INI_ATIVIDADE
		,DATA_FIM_ATIVIDADE
		,Ordem_Tratamento
FROM
		BS_ATIVIDADES
		