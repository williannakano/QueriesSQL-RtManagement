SELECT DISTINCT
		 DimPatientID
		,PatientId
		,PatientId2
		,PatientFullName
		,PatientDateOfBirth
		,PatientType
		,HstryDateTime
		,PatientDeathStatus
		,DR.DoctorFullName
FROM 
					[variandw].[DWH].[DimPatient] AS PT (NOLOCK)
		LEFT JOIN	[variandw].[DWH].[DimDoctor]  AS DR (NOLOCK) ON DR.ctrResourceSer = PT.ctrPrimaryOncologistSer
--order by 1 desc;
