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
