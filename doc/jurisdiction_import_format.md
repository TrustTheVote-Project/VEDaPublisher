Overall: Schema identifier / Locality Source (e.g. something that says "This is provided by Travis County officials and provides mapping from their [System X - there may be many from the same locality, esp over time] to OCD IDs")

TYPE: Precint/District/Split/Ect
ID: (must be unique within Object Class)
NAME: A (hopefully) Friendly identifier
DISTRICT_TYPE: congressional, local, locality, other, state-house, state-senate, statewide (from VSSC - for Districts only) 
OCD_ID: The OCD ID for this place.
Object Type: 
ENCLOSING_IDS: List of items that this object is completely within. Each item should be <Object Class>:<ID> OR an OCD ID (?). If <Object Class>: is ommitted, "District" is assumed
Shape: Shape string

For example (left off 'shape' for simplicity):
TYPE,            ID,           NAME,                        DISTRICT_TYPE,           OCD_ID,                            ENCLOSING_IDS
District,        710,          District 10: Congressional,  (vssc)                   ...state:tx/district:con-10,         
District,        1,            Federal,                     congressional,           country:us,                        
District,        1414,         District 14: Senate          statewide,               state:tx,                          
Precinct,        101,          101,                         state-senate,            ...county:travis/precinct:101,               
Precinct,        102,          102,                                                  ...county:travis/precinct:102,
Precinct-Split,  1,            1,                                                    ...county:travis/precinct-split:1, Precinct:101,country:us,District:710
Precinct-Split,  2,            2,                                                    ...county:travis/precinct-split:2, Precinct:102,country:us,District:1414,District:710

(Or in some cases it may not list the precinct-splits)

Need to figure out the naming conventions and differentiations for things like the "local" version of a state-wide (or country-wide) district.
E.g. Travis county administers the elections in the county, and has the district "all travis county" or "federal elections" for presidential elections or senate elections - is that internal district (the whole county) "part of / inside of" the OCD ID country:us (for president) or country:us/state:tx (for senate) - or is actually the *same* as those districts? For election purposes it's more like a precinct within that district? And for mapping purposes we need it to be different than the whole country?
