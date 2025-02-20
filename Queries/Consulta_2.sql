--Consulta 2 - Diagnósticos: Captura os diagnósticos cadastrados de cada paciente

SELECT DISTINCT
	 PA.DimPatientID
	,LU1.LookupCode					AS Gender
	,DG.HstryUserName 
	,CONVERT(DATE,DG.DateStamp) 	AS DiagnosisDate	
	,DG.DiagnosisCode				
	,DG.Description
	,DC.DiagnosisClinicalDescriptionENU
FROM 
		   		[variandw].[DWH].[DimPatient]		AS PA  (NOLOCK) 
	LEFT JOIN  	[variandw].[DWH].[FactPatient]		AS FP  (NOLOCK)  ON FP.DimPatientID = PA.DimPatientID
	LEFT JOIN  	[variandw].[DWH].DimLookup			AS LU1 (NOLOCK)  ON LU1.DimLookupID = FP.DimLookupID_Gender
	LEFT JOIN  	[VARIAN].[dbo].Diagnosis			AS DG  (NOLOCK)  ON DG.PatientSer = PA.ctrPatientSer
	LEFT JOIN  	[variandw].[DWH].DimDiagnosisCode	AS DC  (NOLOCK)  ON DC.DimDiagnosisCodeID = DG.PatientSer
	LEFT JOIN  	[variandw].[DWH].DimCourse			AS DC1 (NOLOCK)	 ON PA.DimPatientID = DC1.DimPatientID
WHERE
	    1=1
	AND PA.DimPatientID NOT IN (0)
