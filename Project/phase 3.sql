--نمایش پست‌ها به همراه تعداد لایک‌ها، کامنت‌ها و میزان تعامل
CREATE VIEW PostEngagement AS
SELECT p.post_id, p.content AS post_content,
       COUNT(pl.like_id) AS like_count,
       COUNT(c.comment_id) AS comment_count,
       COUNT(pl.like_id) + COUNT(c.comment_id) AS engagement_score
FROM Posts p
LEFT JOIN PostLikes pl ON p.post_id = pl.post_id
LEFT JOIN Comments c ON p.post_id = c.post_id
GROUP BY p.post_id, p.content;

--نمایش پست‌ها به همراه لایک‌ها، کامنت‌ها و بیشترین لایک‌ها
CREATE VIEW PopularPosts AS
SELECT p.post_id, p.content, 
       COUNT(pl.like_id) AS like_count,
       COUNT(c.comment_id) AS comment_count,
       ARRAY(SELECT u.username FROM PostLikes pl2
             JOIN Users u ON pl2.user_id = u.user_id WHERE pl2.post_id = p.post_id) AS likers
FROM Posts p
LEFT JOIN PostLikes pl ON p.post_id = pl.post_id
LEFT JOIN Comments c ON p.post_id = c.post_id
GROUP BY p.post_id, p.content;

--نمایش کاربران به همراه تعداد پست‌ها، استوری‌ها، و لایک‌های دریافت‌شده
CREATE VIEW UserActivity AS
SELECT u.user_id, u.username, COUNT(p.post_id) AS post_count, 
       COUNT(s.story_id) AS story_count,
       (SELECT COUNT(*) FROM PostLikes pl WHERE pl.user_id = u.user_id) AS total_likes
FROM Users u
LEFT JOIN Posts p ON u.user_id = p.user_id
LEFT JOIN Stories s ON u.user_id = s.user_id
GROUP BY u.user_id, u.username;

--نمایش دوستان مشترک بین دو کاربر
CREATE VIEW CommonFriends AS
SELECT f1.follower_id AS user1_id, f2.follower_id AS user2_id, COUNT(f1.follower_id) AS common_friend_count
FROM Follow f1
JOIN Follow f2 ON f1.follower_id = f2.follower_id
WHERE f1.follower_id != f2.follower_id
GROUP BY f1.follower_id, f2.follower_id;

--نمایش دوستانی که بیشتر از یک بار درخواست دوستی فرستاده‌اند
CREATE VIEW RepeatedFriendRequests AS
SELECT sender_id, COUNT(*) AS request_count
FROM FriendRequests
GROUP BY sender_id
HAVING COUNT(*) > 1;

--نمایش درخواست‌های دوستی که هنوز پذیرفته نشده‌اند
CREATE VIEW PendingFriendRequests AS
SELECT f.sender_id, f.receiver_id, u1.username AS sender_username, u2.username AS receiver_username
FROM FriendRequests f
JOIN Users u1 ON f.sender_id = u1.user_id
JOIN Users u2 ON f.receiver_id = u2.user_id
WHERE f.status = 'pending';


--نمایش تعداد پیام‌های خوانده‌نشده برای هر کاربر
CREATE VIEW UnreadMessagesCount AS
SELECT receiver_id, COUNT(*) AS unread_messages
FROM DirectMessages
WHERE is_read = FALSE
GROUP BY receiver_id;

--نمایش لیست استوری‌های کاربر به همراه اطلاعات فالوورها
CREATE VIEW UserStoryFollowers AS
SELECT s.user_id, s.story_id, s.content, u.username
FROM Stories s
JOIN Follow f ON s.user_id = f.following_id
JOIN Users u ON s.user_id = u.user_id;

--نمایش فعالیت‌های کاربر (پست‌ها، لایک‌ها، کامنت‌ها) برای تحلیل تعاملات
CREATE VIEW UserInteractions AS
SELECT u.user_id, u.username, 
       COUNT(p.post_id) AS post_count,
       COUNT(pl.like_id) AS like_count,
       COUNT(c.comment_id) AS comment_count
FROM Users u
LEFT JOIN Posts p ON u.user_id = p.user_id
LEFT JOIN PostLikes pl ON p.post_id = pl.post_id
LEFT JOIN Comments c ON p.post_id = c.post_id
GROUP BY u.user_id, u.username;

--نمایش کاربران فعال بر اساس فعالیت در پست‌ها و استوری‌ها
CREATE VIEW ActiveUsersByActivity AS
SELECT u.user_id, u.username, COUNT(p.post_id) AS posts, COUNT(s.story_id) AS stories
FROM Users u
LEFT JOIN Posts p ON u.user_id = p.user_id
LEFT JOIN Stories s ON u.user_id = s.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(p.post_id) > 0 OR COUNT(s.story_id) > 0;

--ارسال درخواست دوستی با بررسی اینکه آیا درخواست قبلاً ارسال شده است یا نه
CREATE OR REPLACE PROCEDURE SendFriendRequest(
    p_sender_id INT, p_receiver_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM FriendRequests 
                   WHERE sender_id = p_sender_id AND receiver_id = p_receiver_id) THEN
        INSERT INTO FriendRequests (sender_id, receiver_id, status)
        VALUES (p_sender_id, p_receiver_id, 'pending');
    ELSE
        RAISE NOTICE 'Friend request already exists';
    END IF;
END;
$$;

--اعمال تغییرات روی پروفایل کاربر و حفظ تاریخچه تغییرات
CREATE OR REPLACE PROCEDURE UpdateUserProfile(
    p_user_id INT, p_name VARCHAR, p_bio TEXT, p_profile_picture VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO UserProfileHistory (user_id, name, bio, profile_picture, updated_at)
    SELECT p_user_id, p_name, p_bio, p_profile_picture, CURRENT_TIMESTAMP;
    
    UPDATE Users
    SET name = p_name, bio = p_bio, profile_picture = p_profile_picture
    WHERE user_id = p_user_id;
END;
$$;

--محاسبه محبوب‌ترین پست‌ها و استوری‌ها بر اساس لایک و کامنت
CREATE OR REPLACE PROCEDURE CalculatePopularity()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO PopularPostsHistory (post_id, like_count, comment_count, engagement_score)
    SELECT p.post_id, COUNT(pl.like_id), COUNT(c.comment_id), 
           COUNT(pl.like_id) + COUNT(c.comment_id)
    FROM Posts p
    LEFT JOIN PostLikes pl ON p.post_id = pl.post_id
    LEFT JOIN Comments c ON p.post_id = c.post_id
    GROUP BY p.post_id;
END;
$$;

--حذف تمامی درخواست‌های دوستی منقضی‌شده
CREATE OR REPLACE PROCEDURE DeleteExpiredFriendRequests()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM FriendRequests
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '30 days' AND status = 'pending';
END;
$$;

--محاسبه تعداد پیام‌های خوانده‌نشده برای هر کاربر و ارسال نوتیفیکیشن
CREATE OR REPLACE PROCEDURE CountUnreadMessagesAndNotify()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Users
    SET unread_messages = (SELECT COUNT(*) FROM DirectMessages
                            WHERE receiver_id = user_id AND is_read = FALSE)
    WHERE EXISTS (SELECT 1 FROM DirectMessages
                  WHERE receiver_id = user_id AND is_read = FALSE);
END;
$$;

--پذیرش یا رد درخواست دوستی و ارسال نوتیفیکیشن به هر دو طرف
CREATE OR REPLACE PROCEDURE RespondToFriendRequest(
    p_request_id INT, p_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE FriendRequests
    SET status = p_status
    WHERE request_id = p_request_id;

    -- ارسال نوتیفیکیشن به هر دو طرف
    PERFORM SendNotification(p_request_id, p_status);
END;
$$;

--حذف کامنت‌ها و لایک‌های مربوط به یک پست خاص
CREATE OR REPLACE PROCEDURE DeletePostEngagement(
    p_post_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM PostLikes WHERE post_id = p_post_id;
    DELETE FROM Comments WHERE post_id = p_post_id;
END;
$$;

--بررسی و جلوگیری از ارسال محتوای تکراری توسط کاربران
CREATE OR REPLACE PROCEDURE PreventDuplicatePosts(
    p_user_id INT, p_content TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Posts WHERE user_id = p_user_id AND content = p_content) THEN
        RAISE NOTICE 'Duplicate post detected';
    ELSE
        INSERT INTO Posts (user_id, content)
        VALUES (p_user_id, p_content);
    END IF;
END;
$$;

--تحلیل و محاسبه میزان تعاملات برای هر کاربر
CREATE OR REPLACE PROCEDURE CalculateUserEngagement(
    p_user_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO UserEngagementHistory (user_id, post_count, like_count, comment_count, engagement_score)
    SELECT p_user_id,
           COUNT(p.post_id),
           COUNT(pl.like_id),
           COUNT(c.comment_id),
           COUNT(pl.like_id) + COUNT(c.comment_id)
    FROM Posts p
    LEFT JOIN PostLikes pl ON p.post_id = pl.post_id
    LEFT JOIN Comments c ON p.post_id = c.post_id
    WHERE p.user_id = p_user_id;
END;
$$;

--پشتیبان‌گیری از داده‌های کاربران برای بازیابی اطلاعات در مواقع اضطراری
CREATE OR REPLACE PROCEDURE BackupUserData()
LANGUAGE plpgsql
AS $$
BEGIN
    -- پشتیبان‌گیری از جداول کاربر
    INSERT INTO UserBackup (SELECT * FROM Users);
    INSERT INTO PostBackup (SELECT * FROM Posts);
    INSERT INTO StoryBackup (SELECT * FROM Stories);
END;
$$;
