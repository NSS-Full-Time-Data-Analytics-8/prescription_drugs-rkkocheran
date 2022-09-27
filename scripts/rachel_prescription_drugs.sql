/* Q1a
   Which prescriber had the highest total number of claims (totaled over all drugs)?
   Report the npi and the total number of claims.
   ANSWER: npi = 1881634483; total claims = 99707 
SELECT npi,
       sum(total_claim_count) AS sum_claim_count
FROM prescription
GROUP BY npi
ORDER BY sum_claim_count DESC
LIMIT 1;*/

/* Q1b
   Repeat the above, but this time report the nppes_provider_first_name,
   nppes_provider_last_org_name,  specialty_description, and the total number of claims.   
   ANSWER: provider name = "Bruce Pendley"; specialty = "Family Practice"; total claims = 99707 
SELECT p1.nppes_provider_first_name,
       p1.nppes_provider_last_org_name,
       p1.specialty_description,
       sum(p2.total_claim_count) AS sum_claim_count
FROM prescriber AS p1
INNER JOIN prescription AS p2 USING (npi)
GROUP BY p1.npi,
         nppes_provider_first_name,
         nppes_provider_last_org_name,
         p1.specialty_description
ORDER BY sum_claim_count DESC
LIMIT 1;*/

/* Q2a
   Which specialty had the most total number of claims (totaled over all drugs)?
   ANSWER: "Family Practice" with 9752347 total claims 
SELECT specialty_description, sum(total_claim_count) as sum_claim_count
FROM prescriber as p1
INNER JOIN prescription as p2 USING (npi)
GROUP BY specialty_description
ORDER BY sum_claim_count DESC
LIMIT 1;*/

/* Q2b
   Which specialty had the most total number of claims for opioids?
   ANSWER: "Nurse Practitioner" with 900845 total opioid claims 
SELECT specialty_description,
       sum(total_claim_count) AS total_opioid_claim_count
FROM prescriber AS p1
INNER JOIN prescription AS p2 USING (npi)
INNER JOIN drug AS d USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_opioid_claim_count DESC
LIMIT 1;*/

/* Q2c
   **Challenge Question:** Are there any specialties that appear in the prescriber table 
   that have no associated prescriptions in the prescription table?
   ANSWER:  */
SELECT specialty_description
FROM prescriber 
WHERE specialty_description NOT IN 
(SELECT DISTINCT specialty_description
FROM prescriber AS p1
INNER JOIN prescription AS p2 USING (npi) ORDER BY specialty_description)

--SELECT DISTINCT specialty_description from prescriber order by specialty_description