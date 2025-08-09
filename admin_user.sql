INSERT INTO `#__users` (name, username, email, password, block, sendEmail, registerDate, lastvisitDate, activation, params) VALUES 
('Admin', 'joomla', 'joomla@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 0, 1, NOW(), NOW(), '', '{}');

SET @user_id = LAST_INSERT_ID();

INSERT INTO `#__user_usergroup_map` (user_id, group_id) VALUES (@user_id, 8);
