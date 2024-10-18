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
(17, 'Exploring the beauty of nature in my latest adventure!', 'nature_trip.jpg'),
(18, 'Just finished an intense workout session. Feeling great!', 'workout.jpg'),
(17, 'Played a new song today, can’t wait to share it with you all.', 'guitar.jpg'),
(18, 'Life is too short to not enjoy every moment.', 'life_quotes.jpg'),
(19, 'Building my new tech project from scratch!', 'tech_project.jpg'),
(20, 'Captured an amazing sunset at the beach.', 'beach_sunset.jpg'),
(23, 'Tried a new recipe for dinner tonight. Delicious!', 'dinner_recipe.jpg'),
(22, 'New fashion line dropping soon. Stay tuned!', 'fashion_line.jpg');
select * from Posts;
INSERT INTO Stories (user_id, content, image_url, expires_at)
VALUES
(18, 'On top of the world!', 'mountaintop.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(24, 'Prepping for the marathon next week!', 'marathon_prep.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(17, 'Jamming with the band today.', 'band_jam.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(18, 'Chilling at the park.', 'park.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(19, 'Coding late into the night.', 'coding_night.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(22, 'Golden hour at the beach.', 'golden_hour.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(21, 'Baking something special today.', 'baking.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours'),
(21, 'Sneak peek of the new collection!', 'collection_sneak_peek.jpg', CURRENT_TIMESTAMP + INTERVAL '24 hours');
select * from Stories;

INSERT INTO Likes (user_id, story_id)
VALUES
(17,7),
(18,2),
(22,2),
(24,1),
(22,2),
(17,6),
(18,3);
select * from Likes;
INSERT INTO Comments (user_id, post_id, content)
VALUES
(19, 21, 'This is amazing! I love your adventures.'),
(20, 22, 'Great job on the workout! Keep it up!'),
(23, 17, 'Can’t wait to hear the new song!'),
(24, 18, 'So true, life is to be enjoyed every day.'),
(17, 24, 'Looking forward to seeing your tech project!'),
(18, 17, 'That sunset looks incredible!'),
(17, 18, 'That recipe sounds delicious, will try it soon.'),
(18, 19, 'Excited for your new fashion line!');
select * from Comments;
INSERT INTO FriendRequests (sender_id, receiver_id, status)
VALUES
(23, 17, 'accepted'), 
(24, 18, 'pending'), 
(22, 17, 'accepted'), 
(20, 18, 'rejected');
select * from FriendRequests;
INSERT INTO PostLikes (user_id, post_id)
VALUES
(17,17),
(17,18),
(20,21),
(22,20),
(24,17),
(18,19),
(19,24);
select * from PostLikes;
INSERT INTO StoryLikes (user_id, story_id)
VALUES
(17,7),
(18,2),
(22,2),
(24,1),
(22,2),
(17,6),
(18,3);
select * from StoryLikes;
INSERT INTO DirectMessages (sender_id, receiver_id, content)
VALUES
(17, 18, 'Hey, how are you doing?'),
(18, 17, 'I’m doing great, how about you?'),
(22, 19, 'Loved your latest post!'),
(19, 22, 'Thanks! Let’s catch up soon.'),
(24, 20, 'Are you available for a call?'),
(20, 24, 'Sure, let’s schedule something for tomorrow.');
select * from DirectMessages;
INSERT INTO Follow (follower_id, following_id)
VALUES
(20, 18), 
(24, 22), 
(23, 17),
(21, 18), 
(18, 17), 
(17, 22),
(19, 18);
select * from Follow;
INSERT INTO Notes (user_id, content)
VALUES
(17, 'Excited about the upcoming trip!'),
(18, 'Stay positive, stay focused.'),
(19, 'Working on a new project, stay tuned!'),
(20, 'Enjoying the moment. Life is good!'),
(22, 'New collection coming soon!'),
(23, 'Trying out a new recipe today!'),
(24, 'Just finished a great workout. Feeling amazing!');
SELECT * FROM Notes;
