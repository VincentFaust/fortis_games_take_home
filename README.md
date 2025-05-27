![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=snowflakesql&logoColor=white) ![DBT](https://img.shields.io/badge/dbt-FF3621?style=for-the-badge&logo=dbt&logoColor=white)


Codebase
WIP

Under `models`, I've created two directories: `leadership` and `ua_reports`. 

My thought process here is that leadership focus on high level KPIs that help them understand the overall growth and health of the company, whereas UA focused on the tactical levers that drive performance and optimization. 



Architecture Diagram 
WIP


EDA

Before I can make reports for different teams, I have to understand the data I'm working with. My process here is going through each table to ensure I understand what every field means and then specifically looking for integrity issues, which impacts any type of downstream reporting. For example, Any nulls? Any non-deduped ids? etc. Here is how I walked through this: 

I first looked at the `summary reports ad networks` table. At first, the table looks good. No nulls, strong naming conventions, but then....

![mmp_data_integrity](images/adn_no_cost_with_installs.png)

It appears like the MMP is recording installs, but the ad network isn't reporting any cost, impression or click data for those installs. This could be for a few reasons, like the ad network didn't send a postback or the ad network itself wasn't properly connected to the MMP.  

A natural next question is where might these installs be coming from according to the MMP, so I'll turn my attention to `mmp_singular_install_events`. First, I checked if `session_id` and `player_id` had any duplicates, which they didn't. I then was interested in the count of installs by network: 


![mmp_data_integrity](images/tracker_network_installs.png)


So ~ 15% of installs are unattributed, which is bad. It means that these installs were not mapped to any ad network, but at the same time are not marked as organic, which is indicative of spend that is not being tracked. Best guesses as to why are tracking link issues or postbacks between the ad network and mmp have failed. Therefore, we could join installs with the ad networks to see where installs are coming from (or not coming from). 

We can also more user-based questions like from the `start_session_events` table as well, namely are the unattributed installers having sessions? If not, it could be indicative of fraud. First, I verified that session id's are unique and their were no nulls in the table, so we have integrity from that perspective. Second, I was curious about session behavior across all users, which should follow a power law curve, which it does: 


![session_data_integrity](images/power_law_curve.png)


Then I was curious of what session behavior would be like from the unattributed users. We should also expect it to follow a power curve and it does: 

![session_data_integrity](images/power_law_curve_unattributed.png)


This means its far more likely that we just have misattribution, as in these are real users whose install source was lost due to tracking issues.


Semi-related, something else worth looking into is the difference between a users first session and their posted install date (with the assumption that a users' first session fires first and then an install event is sent to the MMP.), which I got as : 

![session_data_integrity](images/install_event_delays.png)

In other words, ~ 85% of installs are recorded within 1 minute, but there is a long tail of installs where the install is recorded well after the first session. This is worthy of looking into. 

Now I wanted to look at revenue. This might just be definition based, but there seems to some sort of an inconsistency between `actual_revenue` and `revenue_d1 + revenue_d7`. My initial thought was that actuals = d1 + d7...but that's not the case. It's possible actuals incorporate revenue beyond what is presented here. It's also possible that `revenue_d1` and `revenue_d7` represent cumulative monetization at those specific points in time. If that is true and we are not missing revenue data then `acutal_revenue` should equal `revenue_d7`. 

However, I found that in 7 out of 31 cases where actualized revenue did not match what is seemingly cumulative monetization at day 7. 



























Question 2 





**What is your team accountable and responsible for vs the teams you support?**

My team is responsible for data integrity, reporting, exploratory data analysis and managing an experimentation road map(think implementing an MMM, incremental testing, analytics trade-offs, tooling etc.). 

My team's outputs are other teams inputs. So for this position, other teams are defined as marketing teams for either 1st or 3rd party. My work should allow them to make better tactical marketing decisions. 



**What are some things you consider important in your partnership with the teams you support?**

I consider communication to be the most important. Everyone has ideas; I have thoughts about how things should be done, as does UA, product, etc. What I’ve found helpful is being able to understand each team’s goals, as in specifically what do they care about, and then communicating insights in a way that speaks to their goals. 


Data teams are a supporting function, but I like to consider myself more of a thought partner. When I’m supporting a team, I don’t want to be the person they come to only after they’ve scoped a question—I want to be involved before that, helping shape how we even think about the problem or where we are going. While not everything is a data question I’ve found that partnering with product/ua/execs on a higher level has enhanced decision making. 

Giving a damn. When people care, they tend to hold a high bar for themselves and others, which I think ultimately translates into a successful product. I'm, individually not looking to "chill" or "coast" at my job and hope the people/teams I work with want to be the best.


**What are your rituals**

The way I think about “rituals” is how I mentally structure my approach to work. My process typically follows three steps: understanding, reasoning, and examining bias.

I start with a first principles mindset: Do I truly understand every component of this problem? If not, I break it down until I reach something foundational and then work my way back up.

From there, I look for the simplest possible explanation first—Occam’s Razor is a powerful tool. While there are usually many ways to approach a problem, I’m often surprised by how frequently the simplest answer turns out to be right. Of course, if the simplest explanation isn’t correct, I move in order of complexity to find an answer. 

Finally, once I’ve built a model or formed a conclusion, I ask: Where might I be wrong? Every line of reasoning carries assumptions, and often bias. I try to surface those: What are my assumptions? What if the opposite were true? What are the edge cases? What's the worst case scenario if I’m wrong? 

Only after I go through this process, will I move forward. 

