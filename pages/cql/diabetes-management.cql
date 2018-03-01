library DiabetesManagement version '1.0'

using FHIR version '3.0.0'

valueset "Abnormal Interpretation Codes": 'observation-interpretation'

parameter DiabetesConditions List<Condition>
parameter CreatinineLabs List<Observation>
parameter HbA1CLabs List<Observation>
parameter LDLLabs List<Observation>
parameter MicroalbCrLabs List<Observation>
parameter FootExams List<Observation>
parameter EyeExams List<Observation>
parameter ACEorARBMedications List<MedicationStatement>

context Patient

define "Has Diabetes":
  exists(
      DiabetesConditions DiabetesCondition
        where DiabetesCondition.clinicalStatus.value = 'active'
          and DiabetesCondition.abatement.value is null
  )

define "Get Last Creatinine Lab Result":
  Last( CreatinineLabs cLabs sort by effective.value )

define "Has Abnormal Creatinine":
  "Get Last Creatinine Lab Result" Result
    return
      ToConcept(Result.interpretation) in "Abnormal Interpretation Codes"

define "Get Creatinine Quantity":
  "Get Last Creatinine Lab Result" Result
    return ToQuantity(Result.value as Quantity)

define "Needs Creatinine Test":
  "Get Last Creatinine Lab Result" Result
    return
      case
        when Result.effective is null
          then true
        when Result.effective is dateTime
          then (Result.effective.value + 1 year) < Today()
        when Result.effective is Period
          then (end of PeriodToInterval(Result.effective) + 1 year) < Today()
        else false
      end

define "Should Consider Ordering Creatinine Test":
  not "Needs Creatinine Test"
  and
    "Get Last Creatinine Lab Result" Result
      return
        case
          when Result.effective is dateTime
            then (Result.effective.value + 10 months) < Today()
          when Result.effective is Period
            then (end of PeriodToInterval(Result.effective) + 10 months) < Today()
          else false
        end

define AbnormalCreatinineSummary:
  'Abnormal Creatinine level detected in most recent lab results'

define AbnormalCreatinineDetail:
  'The Creatinine level of ' + ToString("Get Creatinine Quantity") + ' in the most recent lab is considered abnormal'

define AbnormalCreatinineIndicator:
  'warning'

define "Get Last HbA1C Lab Result":
  Last( HbA1CLabs hLabs sort by effective.value )

define "Has Abnormal HbA1C":
  "Get Last HbA1C Lab Result" Result
    return
      ToConcept(Result.interpretation) in "Abnormal Interpretation Codes"

define "Get HbA1C Quantity":
  "Get Last HbA1C Lab Result" Result
    return ToQuantity(Result.value as Quantity)

define "Needs HbA1C Test":
  "Get Last HbA1C Lab Result" Result
    return
      case
        when Result.effective is null
          then true
        when Result.effective is dateTime
          then (Result.effective.value + 6 months) < Today()
        when Result.effective is Period
          then (end of PeriodToInterval(Result.effective) + 6 months) < Today()
        else false
      end

define "Should Consider Ordering HbA1C Test":
  not "Needs HbA1C Test"
  and
    "Get Last HbA1C Lab Result" Result
      return
        case
          when Result.effective is dateTime
            then (Result.effective.value + 5 months) < Today()
          when Result.effective is Period
            then (end of PeriodToInterval(Result.effective) + 5 months) < Today()
          else false
        end

define AbnormalHbA1CSummary:
  'Abnormal HbA1C level detected in most recent lab results'

define AbnormalHbA1CDetail:
  'The HbA1C level of ' + ToString("Get HbA1C Quantity") + ' in the most recent lab is considered abnormal'

define AbnormalHbA1CIndicator:
  'warning'

define "Get Last LDL Lab Result":
  Last( LDLLabs lLabs sort by effective.value )

define "Has Abnormal LDL":
  "Get Last LDL Lab Result" Result
    return
      ToConcept(Result.interpretation) in "Abnormal Interpretation Codes"

define "Get LDL Quantity":
  "Get Last LDL Lab Result" Result
    return ToQuantity(Result.value as Quantity)

define "Needs LDL Test":
  "Get Last LDL Lab Result" Result
    return
      case
        when Result.effective is null
          then true
        when Result.effective is dateTime
          then (Result.effective.value + 1 year) < Today()
        when Result.effective is Period
          then (end of PeriodToInterval(Result.effective) + 1 year) < Today()
        else false
      end

define "Should Consider Ordering LDL Test":
  not "Needs LDL Test"
  and
    "Get Last LDL Lab Result" Result
      return
        case
          when Result.effective is dateTime
            then (Result.effective.value + 10 months) < Today()
          when Result.effective is Period
            then (end of PeriodToInterval(Result.effective) + 10 months) < Today()
          else false
        end

define AbnormalLDLSummary:
  'Abnormal LDL cholesterol level detected in most recent lab results'

define AbnormalLDLDetail:
  'The LDL cholesterol level of ' + ToString("Get LDL Quantity") + ' in the most recent lab is considered abnormal'

define AbnormalLDLIndicator:
  'warning'

define "Get Last MicroalbCr Lab Result":
  Last( MicroalbCrLabs mLabs sort by effective.value )

define "On ACE or ARB Medication":
  exists(
    ACEorARBMedications Meds
      where Meds.status.value = 'active'
      and Meds.taken.value = 'y'
  )

define "Has Abnormal MicroalbCr":
  "Get Last MicroalbCr Lab Result" Result
    return
      ToConcept(Result.interpretation) in "Abnormal Interpretation Codes"

define "Get MicroalbCr Quantity":
  "Get Last MicroalbCr Lab Result" Result
    return ToQuantity(Result.value as Quantity)

define "Needs MicroalbCr Test":
  "Get Last MicroalbCr Lab Result" Result
    return
      if not "On ACE or ARB Medication"
      then
        case
          when Result.effective is null
            then true
          when Result.effective is dateTime
            then (Result.effective.value + 1 year) < Today()
          when Result.effective is Period
            then (end of PeriodToInterval(Result.effective) + 1 year) < Today()
          else false
        end
      else false

define "Should Consider Ordering MicroalbCr Test":
  not "Needs MicroalbCr Test"
  and not "On ACE or ARB Medication"
  and (
    "Get Last MicroalbCr Lab Result" Result
      return
        case
          when Result.effective is dateTime
            then (Result.effective.value + 10 months) < Today()
          when Result.effective is Period
            then (end of PeriodToInterval(Result.effective) + 10 months) < Today()
          else false
        end
  )

define AbnormalMicroalbCrSummary:
  'Abnormal Microalbumin/Creatinine ratio detected in most recent lab results'

define AbnormalMicroalbCrDetail:
  'The Microalbumin/Creatinine ratio of ' + ToString("Get MicroalbCr Quantity") + ' in the most recent lab is considered abnormal'

define AbnormalMicroalbCrIndicator:
  'warning'

define "Get Last Foot Exam Result":
  Last( FootExams fExams sort by effective.value )

define "Has Abnormal Foot Exam":
  "Get Last Foot Exam Result" Result
    return
      ToConcept(Result.interpretation) in "Abnormal Interpretation Codes"

// TODO: this probably is not what we really want...
define "Get Foot Exam Result":
    "Get Last Foot Exam Result" Result
        return
            if Result.value is CodeableConcept
                then Result.value.coding[0].display
            else null

define "Needs Foot Exam Test":
  "Get Last Foot Exam Result" Result
    return
      case
        when Result.effective is null
          then true
        when Result.effective is dateTime
          then (Result.effective.value + 1 year) < Today()
        when Result.effective is Period
          then (end of PeriodToInterval(Result.effective) + 1 year) < Today()
        else false
      end

define "Should Consider Ordering Foot Exam Test":
  not "Needs Foot Exam Test"
  and
    "Get Last Foot Exam Result" Result
      return
        case
          when Result.effective is dateTime
            then (Result.effective.value + 10 months) < Today()
          when Result.effective is Period
            then (end of PeriodToInterval(Result.effective) + 10 months) < Today()
          else false
        end

define AbnormalFootExamSummary:
  'Abnormal Foot Exam detected in most recent lab results'

define AbnormalFootExamDetail:
  'The Foot Exam resulted in the following abnormality: ' + "Get Foot Exam Result".value

define AbnormalFootExamIndicator:
  'warning'

define "Get Last Eye Exam Result":
  Last( EyeExams eExams sort by effective.value )

define "Has Abnormal Eye Exam":
  "Get Last Eye Exam Result" Result
    return
      ToConcept(Result.interpretation) in "Abnormal Interpretation Codes"

// TODO: this probably is not what we really want...
define "Get Eye Exam Result":
    "Get Last Eye Exam Result" Result
        return
            if Result.value is CodeableConcept
                then Result.value.coding[0].display
            else null

define "Needs Eye Exam":
  "Get Last Eye Exam Result" Result
    return
      case
        when Result.effective is null
          then true
        when Result.effective is dateTime
          then (Result.effective.value + 1 year) < Today()
        when Result.effective is Period
          then (end of PeriodToInterval(Result.effective) + 1 year) < Today()
        else false
      end

define "Should Consider Ordering Eye Exam":
  not "Needs Eye Exam"
  and
    "Get Last Eye Exam Result" Result
      return
        case
          when Result.effective is dateTime
            then (Result.effective.value + 10 months) < Today()
          when Result.effective is Period
            then (end of PeriodToInterval(Result.effective) + 10 months) < Today()
          else false
        end

define AbnormalEyeExamSummary:
  'Abnormal Eye Exam detected in most recent lab results'

define AbnormalEyeExamDetail:
  'The Eye Exam resulted in the following abnormality: ' + "Get Eye Exam Result".value

define AbnormalEyeExamIndicator:
  'warning'

// Conversion functions

define function PeriodToInterval(value FHIR.Period):
	Interval[value."start".value, value."end".value]

define function CodingToCode(coding FHIR.Coding):
	System.Code {
		code: coding.code.value,
		system: coding.system.value,
		version: coding.version.value,
		display: coding.display.value
	}

define function ToConcept(concept FHIR.CodeableConcept):
    System.Concept {
        codes: concept.coding C return CodingToCode(C),
        display: concept.text.value
    }

define function ToQuantity(quantity FHIR.Quantity):
    System.Quantity {
        value: quantity.value.value,
        unit: quantity.unit.value
    }
