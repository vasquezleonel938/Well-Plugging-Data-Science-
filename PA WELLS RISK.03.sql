SELECT 
	 -- Select these to prioritize the information used for data engineering tiers
     API,
	 COUNTY,
	 MUNICIPALITY,
	 WELL_TYPE,
	 WELL_STATUS,
     LONGITUDE,
     LATITUDE,
     
CASE
    -- Comb. Oil and Gas are classified as High Complexity (Combination Hazard) due to their environmental danger 
    WHEN (WELL_TYPE) LIKE '%COMB%' THEN 'High Complexity (Combination Hazard)'
	-- Gas is also High Complexity due to its environmental danger 
    WHEN (WELL_TYPE) LIKE '%GAS%' THEN 'High Complexity'
    -- Multiple Wellbores poses the risk of cross flow from other wells and managing pressure is also High Complexity due to its extreme difficulty 
	WHEN (WELL_TYPE) LIKE '%MULT%' OR (WELL_TYPE) LIKE '%DUAL%' THEN 'High Complexity (Multiple Wellbores)'
    -- Injections are also High Complexity due to missing data, difficult geomechanics and thermodynamics, and pressure
    WHEN (WELL_TYPE) LIKE '%INJECTION%' THEN 'High Complexity'
    -- Oil is still very dangerous but can be more controlled by precise engineering
    WHEN (WELL_TYPE) LIKE '%OIL%' THEN 'Medium Complexity'
    -- The undetermined creates a tier of its own. The unknown is dangerous as you are not sure what they are. 
    WHEN (WELL_TYPE) IS NULL OR (WELL_TYPE) IN ('','UNKNOWN','UNDETERMINED') THEN 'Unknown Physical Danger'
	-- Anything else like a well hole is Low Complexity because it is not harming the environment but should be plugged. 
    ElSE 'Low Complexity'

END AS operational_complexity,

CASE 
        -- Dry Holes — Zero Hazard / Bottom Priority
        WHEN (WELL_TYPE) LIKE '%DRY%' THEN 'Tier 7: Standard Risk (Dry Hole)'
       
       -- Tier 1: Orphaned Combination (Oil & Gas) — Highest Risk
        WHEN (WELL_STATUS) LIKE '%ORPHAN%' AND (WELL_TYPE) LIKE '%COMB%' THEN 'Tier 1: Extreme Danger' 
       
       -- Tier 2: Abandoned Combination (Oil & Gas) — Highest Risk
        WHEN (WELL_STATUS) LIKE '%ABANDONED%' AND (WELL_TYPE) LIKE '%COMB%' THEN 'Tier 2: Extreme Danger' 
      
      -- Tier 3: Orphaned Gas, Injections, and Multi-Wellborne
        WHEN (WELL_STATUS) LIKE '%ORPHAN%' AND (WELL_TYPE) LIKE '%GAS%' THEN 'Tier 3: Moderate-High Danger' 
        WHEN (WELL_STATUS) LIKE '%ORPHAN%' AND (WELL_TYPE) LIKE '%INJECTION%' THEN 'Tier 3: High Danger (Orphaned Injection)'
        WHEN (WELL_STATUS) LIKE '%ORPHAN%' AND (WELL_TYPE) LIKE '%MULT%' OR (WELL_TYPE) LIKE '%DUAL%' THEN 'Tier 3: High Danger (Orphaned Multi-Wellbore)'
       
       -- Tier 4: Orphaned Unknown/Undetermined, Abandoned Injections, Abandoned Multi-Wellbore 
        WHEN(WELL_STATUS) LIKE '%ORPHAN%' AND (WELL_TYPE) IN ('UNDETERMINED', 'UNKNOWN', '', ' ') OR WELL_TYPE IS NULL THEN 'Tier 4: High Danger (Orphaned / Unknown Downhole Profile)'
        WHEN WELL_STATUS LIKE '%ABANDONED%' AND (WELL_TYPE) LIKE '%MULT%' OR (WELL_TYPE) LIKE '%DUAL%' THEN 'Tier 4: Moderate-High Danger (Abandoned Multi-Wellbore)'
        WHEN (WELL_STATUS) LIKE '%ABANDONED%' AND (WELL_TYPE) LIKE '%INJECTION%' THEN 'Tier 4: Moderate-High Danger (Abandoned Injection Well)'
       
       -- Tier 5: Abandoned Gas       
        WHEN UPPER(TRIM(WELL_STATUS)) LIKE '%ABANDONED%' AND (WELL_TYPE) LIKE '%GAS%' THEN 'Tier 5: Moderate Danger' 
      
      -- Tier 6: Orphaned/Abandoned Baseline Oil 
        WHEN (WELL_STATUS) LIKE '%ORPHAN%' AND (WELL_TYPE) LIKE '%OIL%' 
             THEN 'Tier 6: High Planning Priority (Orphaned Oil)'
        
        WHEN (WELL_STATUS) LIKE '%ORPHAN%' THEN 'Tier 6: High Planning Priority' 
        
        WHEN (WELL_STATUS) LIKE '%ABANDONED%' THEN 'Tier 6: Moderate Planning Priority' 
        
        -- Other/Bottom      
        ELSE 'Tier 7: Standard Risk' 
   -- Make a new column
   END AS environmental_priority
	
FROM abandonedwellspa.abandoned_orphan_web

WHERE
	 -- Find using counties in Pennsylvania where Plants and Goodwin are located
	 COUNTY IN ('Allegheny', 'Armstrong', 'Butler', 'Fayette', 'Greene', 'Washington', 'Westmoreland')
	 -- Make sure to find wells that are abandoned and orphaned and not in cancelled or regulatory compliance.
     AND (WELL_STATUS) NOT LIKE '%DEP PLUGGED%'
     AND (WELL_STATUS) NOT IN ('CANCELLED', 'REGULATORY COMPLIANCE')
   
ORDER BY 
    CASE
		-- Rank by Well Type: Methane and Combinations = 1, Methane = 2, Orphaned = 3, Abandoned = 4, Else = 5
        WHEN (WELL_STATUS) LIKE '%METHANE%' AND (WELL_TYPE) LIKE '%COMB%' THEN 1
        WHEN (WELL_STATUS) LIKE '%METHANE%' THEN 2
        WHEN (WELL_STATUS) LIKE '%ORPHAN%' THEN 3
        WHEN (WELL_STATUS) LIKE '%ABANDONED%' THEN 4
        ELSE 5
    END ASC;