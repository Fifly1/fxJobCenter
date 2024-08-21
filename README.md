# fxJobCenter
![fxjobcenter_thumbnail](https://github.com/Fifly1/fxJobCenter/assets/107129715/9c32e7ab-29d1-48d7-ad3a-172dce26deb6)
Free qb job center script for FiveM.

**|Preview|**
[Preview ](https://youtu.be/7KOQgfjkhEQ)

Add this to your database:
CREATE TABLE `fx_jobcenter` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `license` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `job` varchar(30) NOT NULL,
  `applied_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

**|Dependencies|**
qb-core
qb-target (optional)
polyzone
oxmysql (haven't tried others)
fxnotify(optional)
fxtextui(optional)

**|Version 1.1 Update|**

* Script's name is now changable and won't cause any issues.

**|Version 1.2 Update|**

* Added individual webhooks for each whitelist job.

**|Version 1.3 Update|**

* Added individual waypoints for each non-whitelist job. After a player changes to a non-whitelist job, the corresponding waypoint is set on the map. This feature can be turned on or off using the `useWaypoints` variable in the Config.

* Implemented a restriction preventing players currently in a whitelist job from applying to non-whitelist jobs.

**|Version 1.4 Update|**

* The webhook system has been enhanced to automatically split messages that exceed Discord’s limit. This means you can now include unlimited questions and answers with no restrictions on word count.
