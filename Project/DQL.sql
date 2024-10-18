CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    bio TEXT,
    profile_picture VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Posts (
    post_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Stories (
    story_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    content TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);
CREATE TABLE PostLikes (
    like_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    post_id INT REFERENCES Posts(post_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE StoryLikes (
    like_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    story_id INT REFERENCES Stories(story_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Comments (
    comment_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    post_id INT REFERENCES Posts(post_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE DirectMessages (
    message_id SERIAL PRIMARY KEY,
    sender_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    receiver_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE
);
CREATE TABLE FriendRequests (
    request_id SERIAL PRIMARY KEY,
    sender_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    receiver_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending', --pending, accepted, rejected
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Follow (
    follow_id SERIAL PRIMARY KEY,
    follower_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    following_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Notes (
    note_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    content VARCHAR(120) NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '24 hours')
);

INSERT INTO Users (name, username, phone, email, password, bio, profile_picture)
VALUES
('Michael Brown', 'michaelb', '111222333', 'michael@example.com', 'passwordabc', 'Love traveling the world.', 'michael_profile.jpg'),
('Sophia Turner', 'sophiat', '222333444', 'sophia@example.com', 'passworddef', 'Fitness enthusiast.', 'sophia_profile.jpg'),
('David Clark', 'davidc', '333444555', 'david@example.com', 'passwordghi', 'Guitarist and music lover.', 'david_profile.jpg'),
('Lily Evans', 'lilye', '444555666', 'lily@example.com', 'passwordjkl', 'Enjoying life one day at a time.', 'lily_profile.jpg'),
('Oliver Harris', 'oliverh', '555666777', 'oliver@example.com', 'passwordmno', 'Tech geek and software developer.', 'oliver_profile.jpg'),
('Emma Moore', 'emmam', '666777888', 'emma@example.com', 'passwordpqr', 'Photographer and adventurer.', 'emma_profile.jpg'),
('James White', 'jamesw', '777888999', 'james@example.com', 'passwordstu', 'Love to cook and try new recipes.', 'james_profile.jpg'),
('Grace Lee', 'gracel', '888999000', 'grace@example.com', 'passwordvwx', 'Fashion designer and stylist.', 'grace_profile.jpg');
select * from Users;
INSERT INTO Posts (user_id, content, image_url)
VALUES
(7, 'Exploring the beauty of nature in my latest adventure!', 'nature_trip.jpg'),
(8, 'Just finished an intense workout session. Feeling great!', 'workout.jpg'),
(1, 'Played a new song today, can’t wait to share it with you all.', 'guitar.jpg'),
(2, 'Life is too short to not enjoy every moment.', 'life_quotes.jpg'),
(3, 'Building my new tech project from scratch!', 'tech_project.jpg'),
(2, 'Captured an amazing sunset at the beach.', 'beach_sunset.jpg'),
(4, 'Tried a new recipe for dinner tonight. Delicious!', 'dinner_recipe.jpg'),
(5, 'New fashion line dropping soon. Stay tuned!', 'fashion_line.jpg');
select * from Posts;
INSERT INTO Stories (user_id, content, image_url, expires_at)
VALUES
(8, 'On top of the world!', 'mountaintop.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(4, 'Prepping for the marathon next week!', 'marathon_prep.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(7, 'Jamming with the band today.', 'band_jam.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(3, 'Chilling at the park.', 'park.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(8, 'Coding late into the night.', 'coding_night.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(2, 'Golden hour at the beach.', 'golden_hour.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(1, 'Baking something special today.', 'baking.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(1, 'Sneak peek of the new collection!', 'collection_sneak_peek.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours');
select * from Stories;

INSERT INTO Comments (user_id, post_id, content)
VALUES
(1, 2, 'This is amazing! I love your adventures.'),
(7, 2, 'Great job on the workout! Keep it up!'),
(3, 1, 'Can’t wait to hear the new song!'),
(4, 8, 'So true, life is to be enjoyed every day.'),
(7, 4, 'Looking forward to seeing your tech project!'),
(8, 7, 'That sunset looks incredible!'),
(7, 8, 'That recipe sounds delicious, will try it soon.'),
(8, 1, 'Excited for your new fashion line!');
select * from Comments;
INSERT INTO FriendRequests (sender_id, receiver_id, status)
VALUES
(2, 7, 'accepted'), 
(4, 8, 'pending'), 
(2, 7, 'accepted'), 
(2, 1, 'rejected');
select * from FriendRequests;
INSERT INTO PostLikes (user_id, post_id)
VALUES
(7,1),
(7,8),
(2,1),
(2,4),
(4,7),
(8,5),
(7,5);
select * from PostLikes;
INSERT INTO StoryLikes (user_id, story_id)
VALUES
(1,7),
(8,2),
(3,2),
(4,1),
(5,2),
(7,6),
(8,3);
select * from StoryLikes;
INSERT INTO DirectMessages (sender_id, receiver_id, content)
VALUES
(7, 8, 'Hey, how are you doing?'),
(8, 7, 'I’m doing great, how about you?'),
(2, 1, 'Loved your latest post!'),
(1, 2, 'Thanks! Let’s catch up soon.'),
(4, 2, 'Are you available for a call?'),
(2, 4, 'Sure, let’s schedule something for tomorrow.');
select * from DirectMessages;
INSERT INTO Follow (follower_id, following_id)
VALUES
(2, 8), 
(4, 2), 
(3, 1),
(1, 8), 
(8, 7), 
(7, 2),
(1, 8);
select * from Follow;
INSERT INTO Notes (user_id, content)
VALUES
(7, 'Excited about the upcoming trip!'),
(8, 'Stay positive, stay focused.'),
(1, 'Working on a new project, stay tuned!'),
(2, 'Enjoying the moment. Life is good!'),
(2, 'New collection coming soon!'),
(3, 'Trying out a new recipe today!'),
(4, 'Just finished a great workout. Feeling amazing!');
SELECT * FROM Notes;


CREATE OR REPLACE FUNCTION add_follower_on_accept()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Follow (follower_id, following_id, created_at)
    VALUES (NEW.sender_id, NEW.receiver_id, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_friend_request_accept
AFTER UPDATE OF status ON FriendRequests
FOR EACH ROW
WHEN (NEW.status = 'accepted')
EXECUTE FUNCTION add_follower_on_accept();
CREATE OR REPLACE FUNCTION grant_access_on_follow()
RETURNS TRIGGER AS $$
BEGIN
    -- برای اطمینان از این که کاربر فالوور دسترسی دارد
    -- نیاز به این است که قبل از اضافه کردن پست یا استوری، چک شود
    IF EXISTS (SELECT 1 FROM Follow WHERE follower_id = NEW.user_id AND following_id = NEW.user_id) THEN
        RETURN NEW; -- اجازه اضافه کردن
    ELSE
        RAISE EXCEPTION 'Access denied: User is not a follower';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_access_on_post
BEFORE INSERT ON Posts
FOR EACH ROW
EXECUTE FUNCTION grant_access_on_follow();

CREATE TRIGGER check_access_on_story
BEFORE INSERT ON Stories
FOR EACH ROW
EXECUTE FUNCTION grant_access_on_follow();


INSERT INTO FriendRequests (sender_id, receiver_id, status)
VALUES (1, 2, 'pending');
UPDATE FriendRequests
SET status = 'accepted'
WHERE sender_id = 1 AND receiver_id = 2;
SELECT * FROM Follow WHERE follower_id = 1 AND following_id = 2; 
INSERT INTO Posts (user_id, content, image_url)
VALUES (2, 'Just had an amazing day!', 'amazing_day.jpg'); 
INSERT INTO Comments (user_id, post_id, content)
VALUES (1, 2, 'Looks great!'); 
INSERT INTO Comments (user_id, post_id, content)
VALUES (1, 3, 'Looks great!');  
INSERT INTO Comments (user_id, post_id, content)
VALUES (3, 2, 'Nice post!');  