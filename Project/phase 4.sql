------------1.تولید نام کاربری یکتا
CREATE OR REPLACE FUNCTION generate_unique_username(base_name VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    new_username VARCHAR;
BEGIN
    LOOP
        new_username := base_name || floor(random() * 10000)::TEXT;
        IF NOT EXISTS (SELECT 1 FROM Users WHERE username = new_username) THEN
            RETURN new_username;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-------2.ایجاد یادداشت با زمان انقضا
CREATE OR REPLACE FUNCTION create_note(user_id INT, content VARCHAR, expires_in INTERVAL)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Notes (user_id, content, expires_at)
    VALUES (user_id, content, CURRENT_TIMESTAMP + expires_in);
END;
$$ LANGUAGE plpgsql;

---------------حذف استوری‌های منقضی شده
CREATE OR REPLACE FUNCTION delete_expired_stories()
RETURNS VOID AS $$
BEGIN
    DELETE FROM Stories WHERE expires_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-----------3.بررسی دسترسی فالوور به پست‌ها
CREATE OR REPLACE FUNCTION can_view_post(follower_id INT, post_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    owner_id INT;
BEGIN
    -- پیدا کردن صاحب پست
    SELECT user_id INTO owner_id
    FROM Posts
    WHERE post_id = post_id;

    -- بررسی اینکه آیا فالوور است
    RETURN EXISTS (
        SELECT 1
        FROM Follow
        WHERE follower_id = follower_id AND following_id = owner_id
    );
END;
$$ LANGUAGE plpgsql;

------------بررسی دسترسی فالوور به استوری‌ها
CREATE OR REPLACE FUNCTION can_view_story(follower_id INT, story_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    owner_id INT;
BEGIN
    -- پیدا کردن صاحب استوری
    SELECT user_id INTO owner_id
    FROM Stories
    WHERE story_id = story_id;

    -- بررسی اینکه آیا فالوور است
    RETURN EXISTS (
        SELECT 1
        FROM Follow
        WHERE follower_id = follower_id AND following_id = owner_id
    );
END;
$$ LANGUAGE plpgsql;

---------------بررسی دسترسی فالوور به کامنت‌ها
CREATE OR REPLACE FUNCTION can_view_comment(follower_id INT, comment_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    post_owner_id INT;
    commenter_id INT;
BEGIN
    -- پیدا کردن صاحب پست مرتبط با کامنت
    SELECT p.user_id INTO post_owner_id
    FROM Posts p
    JOIN Comments c ON p.post_id = c.post_id
    WHERE c.comment_id = comment_id;

    -- پیدا کردن نویسنده کامنت
    SELECT user_id INTO commenter_id
    FROM Comments
    WHERE comment_id = comment_id;

    -- بررسی اینکه آیا فالوور است یا نویسنده کامنت است
    RETURN EXISTS (
        SELECT 1
        FROM Follow
        WHERE follower_id = follower_id AND following_id = post_owner_id
    ) OR follower_id = commenter_id;
END;
$$ LANGUAGE plpgsql;

-----------بررسی دسترسی فالوور به نوت‌ها
CREATE OR REPLACE FUNCTION can_view_note(follower_id INT, note_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    owner_id INT;
BEGIN
    -- پیدا کردن صاحب نوت
    SELECT user_id INTO owner_id
    FROM Notes
    WHERE note_id = note_id;

    -- بررسی اینکه آیا فالوور است
    RETURN EXISTS (
        SELECT 1
        FROM Follow
        WHERE follower_id = follower_id AND following_id = owner_id
    );
END;
$$ LANGUAGE plpgsql;

------------------------4. بررسی اعتبار یک کاربر در سیستم (ورود کاربر)
CREATE OR REPLACE FUNCTION check_user_credentials(p_email VARCHAR, p_password VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    user_count INT;
BEGIN
    SELECT COUNT(*) INTO user_count
    FROM Users
    WHERE email = p_email AND password = p_password;
    IF user_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;


-------------5.فانکشن برای ارسال اعلان هنگام لایک پست
CREATE OR REPLACE FUNCTION send_like_notification(p_user_id INT, p_post_id INT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Notifications (user_id, message, created_at)
    VALUES (p_user_id, 'Your post has been liked!', CURRENT_TIMESTAMP);
END;
$$ LANGUAGE plpgsql;

------------6.حذف کاربران که یک سال از آخرین ورودشان گذشته است
CREATE OR REPLACE FUNCTION delete_inactive_users()
RETURNS VOID AS $$
BEGIN
    DELETE FROM Users
    WHERE last_login < CURRENT_TIMESTAMP - INTERVAL '1 year';
END;
$$ LANGUAGE plpgsql;

-----------7.فانکشن برای حذف پست‌ها و استوری‌ها بر اساس محتوا
CREATE OR REPLACE FUNCTION delete_sensitive_content()
RETURNS VOID AS $$
DECLARE
    p_record RECORD;
    s_record RECORD;
BEGIN
    -- بررسی پست‌ها: جستجو برای محتوای حساس
    FOR p_record IN
        SELECT post_id, content, image_url FROM Posts
    LOOP
        -- بررسی اینکه آیا محتوا حاوی کلمات حساس است
        IF p_record.content ILIKE '%violence%' OR p_record.content ILIKE '%18+' OR p_record.image_url ILIKE '%blood%' THEN
            DELETE FROM Posts WHERE post_id = p_record.post_id;
        END IF;
    END LOOP;
    -- بررسی استوری‌ها: جستجو برای محتوای حساس
    FOR s_record IN
        SELECT story_id, content, image_url FROM Stories
    LOOP
        -- بررسی اینکه آیا محتوا حاوی کلمات حساس است
        IF s_record.content ILIKE '%violence%' OR s_record.content ILIKE '%18+' OR s_record.image_url ILIKE '%blood%' THEN
            DELETE FROM Stories WHERE story_id = s_record.story_id;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
--------------------8.بلاک کردن
CREATE OR REPLACE FUNCTION block_user(blocker INT, blocked INT)
RETURNS VOID AS $$
DECLARE
    is_blocked BOOLEAN;
BEGIN
    -- بررسی اینکه کاربر نمی‌تواند خود را بلاک کند
    IF blocker = blocked THEN
        RAISE EXCEPTION 'You cannot block yourself.';
    END IF;

    -- بررسی اینکه آیا این کاربر قبلاً مسدود شده است یا خیر
    -- این چک فقط در صورت نیاز به مسدود کردن کاربر جدید استفاده می‌شود
    SELECT EXISTS (SELECT 1 FROM BlockList WHERE blocker_id = blocker AND blocked_id = blocked) INTO is_blocked;

    IF is_blocked THEN
        RAISE NOTICE 'User % is already blocked by %.', blocked, blocker;
        RETURN;
    END IF;

    -- در اینجا با توجه به شرایط بلاک کردن باید پست‌ها و استوری‌ها و پیام‌ها محدود شوند.
    -- فرض بر این است که بررسی برای دسترسی به داده‌های مختلف در بخش‌های مختلف انجام می‌شود
    -- به‌طور مثال:
    -- حذف لایک‌ها و نظرات و پیام‌ها و سایر ارتباطات:
    
    DELETE FROM PostLikes WHERE user_id = blocked AND post_id IN (SELECT post_id FROM Posts WHERE user_id = blocker);
    DELETE FROM StoryLikes WHERE user_id = blocked AND story_id IN (SELECT story_id FROM Stories WHERE user_id = blocker);
    DELETE FROM DirectMessages WHERE (sender_id = blocker AND receiver_id = blocked) OR (sender_id = blocked AND receiver_id = blocker);
    DELETE FROM Comments WHERE user_id = blocked AND post_id IN (SELECT post_id FROM Posts WHERE user_id = blocker);
    
    -- در اینجا می‌توانید دسترسی‌های مربوط به مشاهده پست‌ها یا استوری‌ها را محدود کنید.
    -- به عنوان مثال، جلوگیری از مشاهده پست‌ها و استوری‌ها توسط کاربران بلاک شده:
    RAISE NOTICE 'User % has been blocked by % and access to posts and stories is restricted.', blocked, blocker;
END;
$$ LANGUAGE plpgsql;


-------9.هاید کردن فالوور از استوری
CREATE OR REPLACE FUNCTION hide_follower_from_story(user_id INT, follower_id INT)
RETURNS VOID AS $$
DECLARE
    is_following BOOLEAN;
BEGIN
    -- بررسی می‌کنیم که آیا فالوور، کاربر را فالو می‌کند یا خیر
    SELECT EXISTS (SELECT 1 FROM Follow WHERE follower_id = follower_id AND following_id = user_id) INTO is_following;

    -- اگر فالوور کاربر را فالو نکند، نمی‌توانیم او را از استوری‌ها مخفی کنیم
    IF NOT is_following THEN
        RAISE EXCEPTION 'User % is not following user %.', follower_id, user_id;
    END IF;

    -- در اینجا باید به گونه‌ای عمل کنیم که استوری‌های کاربر برای فالوور مخفی شوند
    -- برای این منظور فرض می‌کنیم که یک جدول برای مشاهده استوری‌ها وجود دارد که دسترسی‌ها را محدود می‌کند:
    
    --  حذف دسترسی فالوور به استوری‌های کاربر
    DELETE FROM StoryLikes
    WHERE story_id IN (SELECT story_id FROM Stories WHERE user_id = user_id)
    AND user_id = follower_id;

    -- اگر لازم باشد که استوری‌های جدید را هم برای فالوور مخفی کنیم، در اینجا باید استوری‌های جدید را هم بررسی کنیم
    -- مانع مشاهده استوری‌ها توسط فالوور
    RAISE NOTICE 'User % has been hidden from viewing stories of user %.', follower_id, user_id;
END;
$$ LANGUAGE plpgsql;

----------------10.آرشیو کردن پست
CREATE OR REPLACE FUNCTION archive_post(post_id INT, user_id INT)
RETURNS VOID AS $$
DECLARE
    post_owner INT;
BEGIN
    -- بررسی می‌کنیم که آیا کاربر مورد نظر صاحب پست است یا خیر
    SELECT user_id INTO post_owner FROM Posts WHERE post_id = post_id;

    IF post_owner IS NULL THEN
        RAISE EXCEPTION 'Post with ID % does not exist.', post_id;
    END IF;

    IF post_owner != user_id THEN
        RAISE EXCEPTION 'User % does not have permission to archive this post.', user_id;
    END IF;

    -- آرشیو کردن پست با تغییر وضعیت 'archived' به TRUE
    UPDATE Posts
    SET archived = TRUE
    WHERE post_id = post_id;

    -- اطلاع‌رسانی به کاربر
    RAISE NOTICE 'Post % has been archived.', post_id;
END;
$$ LANGUAGE plpgsql;

----------1.حذف لایک‌های مرتبط با پست هنگام حذف آن
CREATE OR REPLACE FUNCTION delete_post_likes()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM PostLikes WHERE post_id = OLD.post_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_delete_post_likes
AFTER DELETE ON Posts
FOR EACH ROW
EXECUTE FUNCTION delete_post_likes();

------------------حذف نظرات مرتبط با پست هنگام حذف آن
CREATE OR REPLACE FUNCTION delete_post_comments()
RETURNS TRIGGER AS $$
BEGIN
    -- حذف تمام نظرات مرتبط با پستی که در حال حذف شدن است
    DELETE FROM Comments
    WHERE post_id = OLD.post_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- ایجاد تریگر برای جدول Posts
CREATE TRIGGER trigger_delete_post_comments
AFTER DELETE ON Posts
FOR EACH ROW
EXECUTE FUNCTION delete_post_comments();


---------------------2.اعلان هنگام ارسال پیام خصوصی جدید
CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'New message sent from % to %', NEW.sender_id, NEW.receiver_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_message
AFTER INSERT ON DirectMessages
FOR EACH ROW
EXECUTE FUNCTION notify_new_message();

------------3.پاک‌سازی یادداشت‌های منقضی شده به صورت خودکار
CREATE OR REPLACE FUNCTION cleanup_expired_notes()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM Notes WHERE expires_at < CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cleanup_notes
AFTER INSERT ON Notes
FOR EACH ROW
EXECUTE FUNCTION cleanup_expired_notes();

---------------4.بروزرسانی تعداد فالوئر هنگام اضافه شدن فالو جدید
CREATE OR REPLACE FUNCTION increment_follow_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Users SET bio = bio || ' (New follower!)' WHERE user_id = NEW.following_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_follow
AFTER INSERT ON Follow
FOR EACH ROW
EXECUTE FUNCTION increment_follow_count();

--------------------5.اعلان هنگام حذف یک کاربر
CREATE OR REPLACE FUNCTION notify_user_deletion()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'User with ID % deleted.', OLD.user_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_user_deletion
AFTER DELETE ON Users
FOR EACH ROW
EXECUTE FUNCTION notify_user_deletion();

-------------------------6.ارسال اعلان هنگام اضافه شدن کامنت به پست
-- تابع برای ثبت پیام اعلان در لاگ سرور
CREATE OR REPLACE FUNCTION notify_on_comment()
RETURNS TRIGGER AS $$
BEGIN
    -- ثبت پیام در لاگ سرور
    RAISE NOTICE 'New comment on Post ID % by User ID %: %', NEW.post_id, NEW.user_id, NEW.content;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ایجاد تریگر برای جدول Comments
CREATE TRIGGER trigger_notify_on_comment
AFTER INSERT ON Comments
FOR EACH ROW
EXECUTE FUNCTION notify_on_comment();
----------7.جلوگیری از لایک کردن یک پست بیشتر از 3 بار
CREATE OR REPLACE FUNCTION prevent_multiple_likes()
RETURNS TRIGGER AS $$
BEGIN
    -- بررسی اگر کاربر قبلاً پست را لایک کرده است
    IF EXISTS (SELECT 1 FROM PostLikes WHERE user_id = NEW.user_id AND post_id = NEW.post_id) THEN
        RAISE EXCEPTION 'User has already liked this post';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_prevent_multiple_likes
BEFORE INSERT ON PostLikes
FOR EACH ROW
EXECUTE FUNCTION prevent_multiple_likes();

----------------8.هنگام حذف حساب کاربری، تمامی پست‌ها، نظرات مرتبط با آن، استوری‌ها و کامنت‌های مربوط به آن کاربر را حذف کند
CREATE OR REPLACE FUNCTION delete_user_content()
RETURNS TRIGGER AS $$
BEGIN
    -- حذف تمامی پست‌های کاربر
    DELETE FROM Posts WHERE user_id = OLD.user_id;

    -- حذف تمامی نظرات مرتبط با پست‌های کاربر
    DELETE FROM Comments WHERE user_id = OLD.user_id;

    -- حذف تمامی لایک‌های پست‌های کاربر
    DELETE FROM PostLikes WHERE user_id = OLD.user_id;

    -- حذف تمامی استوری‌های کاربر
    DELETE FROM Stories WHERE user_id = OLD.user_id;

    -- حذف تمامی لایک‌های استوری‌های کاربر
    DELETE FROM StoryLikes WHERE user_id = OLD.user_id;

    -- حذف تمامی پیام‌های دایرکت ارسال شده توسط کاربر
    DELETE FROM DirectMessages WHERE sender_id = OLD.user_id;

    -- حذف تمامی درخواست‌های دوستی ارسال شده یا دریافت شده توسط کاربر
    DELETE FROM FriendRequests WHERE sender_id = OLD.user_id OR receiver_id = OLD.user_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_delete_user_content
AFTER DELETE ON Users
FOR EACH ROW
EXECUTE FUNCTION delete_user_content();

------------------9.هنگام حذف پست یا استوری به دلیل نقض کپی‌رایت یا محتوای خشونت‌آمیز، یک اعلان به کاربر ارسال کند
CREATE OR REPLACE FUNCTION send_notification_on_deletion()
RETURNS TRIGGER AS $$
BEGIN
    -- چک می‌کنیم که آیا پست یا استوری حذف شده است
    IF (TG_OP = 'DELETE') THEN
        -- ارسال اطلاع‌رسانی به کنسول
        RAISE NOTICE 'Your post/story has been deleted due to copyright infringement or inappropriate content. User ID: %, Post ID: %', OLD.user_id, OLD.post_id;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- تریگر برای حذف پست‌ها به دلیل نقض کپی‌رایت یا خشونت
CREATE TRIGGER trigger_send_notification_on_post_deletion
AFTER DELETE ON Posts
FOR EACH ROW
EXECUTE FUNCTION send_notification_on_deletion();

-- تریگر برای حذف استوری‌ها به دلیل نقض کپی‌رایت یا خشونت
CREATE TRIGGER trigger_send_notification_on_story_deletion
AFTER DELETE ON Stories
FOR EACH ROW
EXECUTE FUNCTION send_notification_on_deletion();

--------------------10. تریگر برای بررسی فعالیت‌های مشکوک (اسپم) در پست‌ها
CREATE OR REPLACE FUNCTION check_for_spam_activity()
RETURNS TRIGGER AS $$
DECLARE
    post_count INT;
BEGIN
    -- تعداد پست‌های اخیر کاربر را می‌شماریم
    SELECT COUNT(*) INTO post_count
    FROM Posts
    WHERE user_id = NEW.user_id
    AND created_at > CURRENT_TIMESTAMP - INTERVAL '1 hour';

    -- اگر تعداد پست‌ها بیشتر از 5 باشد، این احتمال وجود دارد که اسپم باشد
    IF post_count > 5 THEN
        -- می‌توان یک هشدار به مدیریت یا سیستم ارسال کرد که این کاربر ممکن است اسپم باشد
        RAISE NOTICE 'User % might be posting spam. More than 5 posts within 1 hour.', NEW.user_id;

        -- در اینجا می‌توان اقداماتی مانند بلاک کردن موقت کاربر، ارسال هشدار و غیره را انجام داد
        -- مثلاً می‌توانیم یک وضعیت به جدول کاربران اضافه کنیم یا پست‌ها را در وضعیت غیر فعال قرار دهیم
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- تریگر برای بررسی پست‌های مشکوک و اسپم
CREATE TRIGGER trigger_check_for_spam_activity
AFTER INSERT ON Posts
FOR EACH ROW
EXECUTE FUNCTION check_for_spam_activity();

----------------11.جلوگیری از ارسال پست‌های تکراری
CREATE OR REPLACE FUNCTION prevent_duplicate_posts()
RETURNS TRIGGER AS $$
BEGIN
    -- بررسی اینکه آیا پست مشابهی قبلاً در این بازه زمانی وجود دارد
    IF EXISTS (
        SELECT 1 FROM Posts
        WHERE user_id = NEW.user_id
        AND content = NEW.content
        AND created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours'
    ) THEN
        -- اگر پست مشابه وجود داشته باشد، این پست را حذف می‌کنیم
        DELETE FROM Posts WHERE post_id = NEW.post_id;
        RAISE NOTICE 'Duplicate post detected and deleted for user %.', NEW.user_id;
    END IF;

    RETURN NULL; -- در اینجا چون پست حذف شده است، باید NULL برگشت داده شود
END;
$$ LANGUAGE plpgsql;

-- تریگر برای جلوگیری از ارسال پست‌های تکراری
CREATE TRIGGER trigger_prevent_duplicate_posts
AFTER INSERT ON Posts
FOR EACH ROW
EXECUTE FUNCTION prevent_duplicate_posts();
