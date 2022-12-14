/* Q1a
   Which prescriber had the highest total number of claims (totaled over all drugs)?
   Report the npi and the total number of claims.
   ANSWER: npi = 1881634483; total claims = 99707
SELECT npi,
       sum(total_claim_count) AS sum_claim_count
FROM prescription
GROUP BY npi
ORDER BY sum_claim_count DESC
LIMIT 1;*/ /* Q1b
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
LIMIT 1;*/ /* Q2a
   Which specialty had the most total number of claims (totaled over all drugs)?
   ANSWER: "Family Practice" with 9752347 total claims
SELECT specialty_description, sum(total_claim_count) as sum_claim_count
FROM prescriber as p1
INNER JOIN prescription as p2 USING (npi)
GROUP BY specialty_description
ORDER BY sum_claim_count DESC
LIMIT 1;*/ /* Q2b
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
   ANSWER: Yes, there are 15 specialties that have not prescribed anything. Namely,
   "Ambulatory Surgical Center"
   "Chiropractic"
   "Contractor"
   "Developmental Therapist"
   "Hospital"
   "Licensed Practical Nurse"
   "Marriage & Family Therapist"
   "Medical Genetics"
   "Midwife"
   "Occupational Therapist in Private Practice"
   "Physical Therapist in Private Practice"
   "Physical Therapy Assistant"
   "Radiology Practitioner Assistant"
   "Specialist/Technologist, Other"
   "Undefined Physician type" 
SELECT DISTINCT specialty_description
FROM prescriber
WHERE specialty_description NOT IN
    (SELECT DISTINCT specialty_description
     FROM prescription AS p1
     INNER JOIN prescriber AS p2 USING (npi))
ORDER BY specialty_description;*/

/* Q3a
   Which drug (generic_name) had the highest total drug cost?
   ANSWER: "PIRFENIDONE" with "$2,829,174.30" 

SELECT generic_name, total_drug_cost::money
FROM prescription as p
INNER JOIN drug as d USING (drug_name)
ORDER BY total_drug_cost DESC
LIMIT 1;*/

/* Q3B
   Which drug (generic_name) has the highest total cost per day? 
   **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
   ANSWER: "C1 ESTERASE INHIBITOR" with $3,495.22/day 
SELECT generic_name,
       round((sum(total_drug_cost) / sum(total_day_supply)), 2)::MONEY AS drug_cost_per_day
FROM prescription AS p
INNER JOIN drug AS d USING (drug_name)
GROUP BY generic_name
ORDER BY drug_cost_per_day DESC
LIMIT 1;*/

/* Q4a
   For each drug in the drug table, return the drug name and then a column named 'drug_type' which 
   says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which 
   have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
   ANSWER: (see below) 
SELECT drug_name,
       CASE
           WHEN opioid_drug_flag = 'Y' THEN 'opioid'
           WHEN long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
           WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
           ELSE 'neither'
       END AS drug_type
FROM drug;*/

/* Q4b
   Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) 
   on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
   ANSWER: "opioid" with "$105,080,626.37" total cost. 

SELECT drug_type,
       sum(total_drug_cost)::MONEY AS sum_drug_cost
FROM prescription AS p
INNER JOIN
  (SELECT drug_name,
          CASE
              WHEN opioid_drug_flag = 'Y' THEN 'opioid'
              WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
              ELSE 'neither'
          END AS drug_type
   FROM drug) AS d USING (drug_name)
WHERE drug_type IN ('opioid',
                    'antibiotic')
GROUP BY d.drug_type
ORDER BY sum_drug_cost DESC;*/
   
/* Q5a
   How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information 
   for all states, not just Tennessee.
   ANSWER: 33 
SELECT count(*)
FROM cbsa
WHERE right(cbsaname, 2) ilike 'TN';*/

/* Q5b
   Which cbsa has the largest combined population? Which has the smallest? 
   Report the CBSA name and total population.
   ANSWER:
   Largest: 34980 (cbsa), "Nashville-Davidson--Murfreesboro--Franklin, TN" (cbsaname), 1830410 (population)
   Smallest: 34100, "Morristown, TN", 116352 
SELECT cbsa,
       cbsaname,
       sum(population) AS total_population
FROM cbsa
INNER JOIN population USING (fipscounty)
GROUP BY cbsa,
         cbsaname
ORDER BY total_population DESC;*/

/* Q5c
   What is the largest (in terms of population) county which is not included in a CBSA? 
   Report the county name and population.
   ANSWER: "SEVIER" with 95523 total population. 

SELECT county,
       sum(population) AS total_population
FROM fips_county
INNER JOIN population AS p USING (fipscounty)
WHERE fipscounty NOT IN
    (SELECT DISTINCT fipscounty
     FROM cbsa)
GROUP BY county
ORDER BY total_population DESC
LIMIT 1;*/

/* Q6a
   Find all rows in the prescription table where total_claims is at least 3000. 
   Report the drug_name and the total_claim_count.

SELECT drug_name,
       total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;*/

/* Q6b 
   For each instance that you found in part a, add a column that indicates whether the drug is an opioid. 

SELECT d.drug_name,
       total_claim_count,
       opioid_drug_flag
FROM prescription as p
INNER JOIN drug as d USING (drug_name)
WHERE total_claim_count >= 3000;*/

/* Q6c
   Add another column to you answer from the previous part which gives the prescriber first and 
   last name associated with each row. 

WITH top_claims AS(
SELECT npi,
       d.drug_name,
       total_claim_count,
       opioid_drug_flag
FROM prescription as p
INNER JOIN drug as d USING (drug_name)
WHERE total_claim_count >= 3000)

SELECT nppes_provider_first_name,
       nppes_provider_last_org_name,
       drug_name,
       total_claim_count,
       opioid_drug_flag
FROM prescriber AS p
INNER JOIN top_claims AS t USING (npi);*/

/* Q7 
   Goal: Generate a full list of all pain management specialists in Nashville and 
   the number of claims they had for each opioid.
   
   Q7a
   Create a list of all npi/drug_name combinations for pain management specialists 
   (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), 
   where the drug is an opioid (opiod_drug_flag = 'Y'). 
   **Warning:** Double-check your query before running it. You will only need to use the prescriber 
   and drug tables since you don't need the claims numbers yet. */

WITH nashville_opioid AS (
SELECT npi,
       nppes_provider_first_name,
       nppes_provider_last_org_name,
       nppes_provider_city,
       specialty_description,
       drug_name,
       opioid_drug_flag
FROM prescriber AS p
CROSS JOIN drug AS d
WHERE nppes_provider_city = 'NASHVILLE'
  AND specialty_description = 'Pain Management'
  AND opioid_drug_flag = 'Y')


/* Q7b
   Next, report the number of claims per drug per prescriber. Be sure to include all combinations, 
   whether or not the prescriber had any claims. You should report the npi, the drug name, and the 
   number of claims (total_claim_count). */
--UNFINISHED
SELECT *
FROM nashville_opioid as n
LEFT JOIN prescription as p USING (npi);

/* Q7c
   Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function. */
--UNFINISHED
