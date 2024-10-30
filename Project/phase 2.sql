----نمایش کاربرانی که پستی دارند که هیچ‌کس آن را لایک نکرده است
SELECT u.username
FROM Users u
JOIN Posts p ON u.user_id = p.user_id
LEFT JOIN PostLikes pl ON p.post_id = pl.post_id
WHERE pl.like_id IS NULL;

----نمایش کاربران با بیشترین ارسال پیام خصوصی (Direct Message) به دیگران
SELECT u.username, COUNT(dm.message_id) AS total_messages
FROM Users u
JOIN DirectMessages dm ON u.user_id = dm.sender_id
GROUP BY u.user_id
ORDER BY total_messages DESC
LIMIT 5;

----نمایش دو کاربری که بیشترین پیام را به یکدیگر ارسال کرده‌اند (ارتباط دو طرفه)
SELECT u1.username AS sender, u2.username AS receiver, COUNT(dm.message_id) AS message_count
FROM DirectMessages dm
JOIN Users u1 ON dm.sender_id = u1.user_id
JOIN Users u2 ON dm.receiver_id = u2.user_id
GROUP BY u1.username, u2.username
ORDER BY message_count DESC
LIMIT 1;

----پست‌های کاربرانی که حداقل در دو استوری لایک شده‌اند
SELECT p.content, u.username
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
WHERE u.user_id IN (
    SELECT user_id
    FROM StoryLikes
    GROUP BY user_id
    HAVING COUNT(story_id) >= 2
);

---کاربرانی که با هم دوست هستند و حداقل ۳ لایک مشترک بر روی پست‌های یکدیگر دارند
SELECT u1.username AS user1, u2.username AS user2
FROM FriendRequests fr
JOIN Users u1 ON fr.sender_id = u1.user_id
JOIN Users u2 ON fr.receiver_id = u2.user_id
WHERE fr.status = 'accepted' AND (
    SELECT COUNT(*) 
    FROM PostLikes pl
    WHERE (pl.user_id = u1.user_id AND pl.post_id IN (SELECT post_id FROM Posts WHERE user_id = u2.user_id)) OR 
          (pl.user_id = u2.user_id AND pl.post_id IN (SELECT post_id FROM Posts WHERE user_id = u1.user_id))
) >= 3;


----یافتن پست‌هایی که هیچ کامنتی ندارند اما حداقل ۵ لایک دارند
SELECT p.content
FROM Posts p
LEFT JOIN Comments c ON p.post_id = c.post_id
LEFT JOIN PostLikes pl ON p.post_id = pl.post_id
GROUP BY p.post_id
HAVING COUNT(c.comment_id) = 0 AND COUNT(pl.like_id) >= 5;


----نمایش کاربرانی که بیش از یک‌بار درخواست دوستی به کاربر دیگری ارسال کرده‌اند و وضعیت‌های متفاوتی دارند
SELECT sender_id, receiver_id
FROM FriendRequests
GROUP BY sender_id, receiver_id
HAVING COUNT(DISTINCT status) > 1;


----نمایش پست‌هایی که در همان روزی ایجاد شده‌اند که کاربر سازنده‌اش ثبت‌نام کرده است
SELECT p.content, u.username
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
WHERE DATE(p.created_at) = DATE(u.created_at);


----کاربرانی که همزمان درخواست دوستی و فالو از کاربر خاصی دریافت کرده‌اند
SELECT u.username
FROM Users u
WHERE EXISTS (SELECT 1 FROM FriendRequests fr WHERE fr.receiver_id = u.user_id AND fr.sender_id = 1)
  AND EXISTS (SELECT 1 FROM Follow f WHERE f.following_id = u.user_id AND f.follower_id = 1);

----نمایش استوری‌هایی که کاربران لایک کرده‌اند، اما هیچ پستی از آن‌ها لایک نکرده‌اند
SELECT s.content, u.username
FROM Stories s
JOIN StoryLikes sl ON s.story_id = sl.story_id
JOIN Users u ON sl.user_id = u.user_id
WHERE NOT EXISTS (SELECT 1 FROM PostLikes pl WHERE pl.user_id = u.user_id);

----کاربرانی که دقیقاً دو یادداشت (Notes) دارند و یادداشت دومشان منقضی شده است
SELECT u.username
FROM Users u
JOIN Notes n ON u.user_id = n.user_id
GROUP BY u.user_id
HAVING COUNT(n.note_id) = 2 AND MAX(n.expires_at) < CURRENT_TIMESTAMP;

----نمایش لیستی از کاربران با تعداد پست‌ها و تعداد استوری‌هایشان
SELECT u.username, 
       (SELECT COUNT(*) FROM Posts WHERE user_id = u.user_id) AS post_count,
       (SELECT COUNT(*) FROM Stories WHERE user_id = u.user_id) AS story_count
FROM Users u;

----کاربرانی که بیشترین تعداد لایک را در پست‌های خود دارند (بیش از ۱۰ لایک)
SELECT u.username, COUNT(pl.like_id) AS total_likes
FROM Users u
JOIN Posts p ON u.user_id = p.user_id
JOIN PostLikes pl ON p.post_id = pl.post_id
GROUP BY u.user_id
HAVING COUNT(pl.like_id) > 10
ORDER BY total_likes DESC;

----یافتن پیام‌های خصوصی که فقط در تاریخ مشخصی ارسال شده‌اند و هنوز خوانده نشده‌اند
SELECT dm.content, dm.created_at, u.username AS sender
FROM DirectMessages dm
JOIN Users u ON dm.sender_id = u.user_id
WHERE DATE(dm.created_at) = '2024-10-23' AND dm.is_read = FALSE;

----نمایش کاربرانی که پس از ارسال یک پست، فوراً یک استوری ایجاد کرده‌اند (اختلاف زمانی کمتر از یک ساعت)
SELECT u.username, p.content AS post_content, s.content AS story_content
FROM Users u
JOIN Posts p ON u.user_id = p.user_id
JOIN Stories s ON u.user_id = s.user_id
WHERE s.created_at > p.created_at AND s.created_at - p.created_at < INTERVAL '1 hour';
