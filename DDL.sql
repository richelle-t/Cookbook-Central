-- Active: 1721152435454@@127.0.0.1@3306@cs340
SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT = 0;

# Create users table
DROP TABLE IF EXISTS Users;
CREATE TABLE Users (
    userID int NOT NULL AUTO_INCREMENT,
    firstName VARCHAR(45) NOT NULL,
    lastName VARCHAR(45) NOT NULL,
    email VARCHAR(45) UNIQUE NOT NULL,
    PRIMARY KEY (userID)
);

# Create recipes table. ON DELETE SET NULL allows for the users own recipes to be kept by the database if a user is deleted.
DROP TABLE IF EXISTS Recipes;
CREATE TABLE Recipes (
    recipeID int NOT NULL AUTO_INCREMENT,
    userID int,
    name VARCHAR(45) NOT NULL,
    mealType VARCHAR(45),
    duration int,
    servingSize int,
    totalCost float,
    directions VARCHAR(2000) NOT NULL,
    PRIMARY KEY (recipeID),
    CONSTRAINT FK_Recipes_userID FOREIGN KEY (userID)
    REFERENCES Users(userID)
    ON DELETE SET NULL
);

# Creates ingredients table
DROP TABLE IF EXISTS Ingredients;
CREATE TABLE Ingredients (
    ingredientID int NOT NULL AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    cost FLOAT,
    PRIMARY KEY (ingredientID)
);

# Creates review table. ON DELETE CASCADE allows for the reviews to be deleted if the recipe is deleted. ON DELETE SET NULL allows for reviews to be kept if the user who made the reveiw is deleted.
DROP TABLE IF EXISTS Reviews;
CREATE TABLE Reviews (
    reviewID int NOT NULL AUTO_INCREMENT,
    recipeID int,
    userID int,
    date date NOT NULL,
    rating int NOT NULL,
    comment VARCHAR(1000),
    PRIMARY KEY (reviewID),
    CONSTRAINT FK_Reviews_recipeID FOREIGN KEY (recipeID)
    REFERENCES Recipes(recipeID)
    ON DELETE CASCADE,
    CONSTRAINT FK_Reviews_userID FOREIGN KEY (userID)
    REFERENCES Users(userID)
    ON DELETE SET NULL
);

# Creates RecipeIngredients table. ON DELETE CASCADE allows for the row to be deleted if the recipe is deleted. ON DELETE RESTRICT prevents ingredients to be deleted if is in this table.
DROP TABLE IF EXISTS RecipeIngredients;
CREATE TABLE RecipeIngredients (
    recipeIngredientID int NOT NULL AUTO_INCREMENT,
    recipeID int,
    ingredientID int,
    quantity VARCHAR(10) NOT NULL,
    unit VARCHAR(45),
    PRIMARY KEY (recipeIngredientID),
    CONSTRAINT FK_RecipeIngredients_recipeID FOREIGN KEY (recipeID)
    REFERENCES Recipes(recipeID)
    ON DELETE CASCADE,
    CONSTRAINT FK_RecipeIngredients_ingredientID FOREIGN KEY (ingredientID)
    REFERENCES Ingredients(ingredientID)
    ON DELETE RESTRICT
);

# Creates SavedRecipes table. ON DELETE CASCADE allows for the row to be deleted if either the user is deleted or the recipe is deleted.
DROP TABLE IF EXISTS SavedRecipes;
CREATE TABLE SavedRecipes (
    savedRecipeID int NOT NULL AUTO_INCREMENT,
    userID int,
    recipeID int,
    PRIMARY KEY (savedRecipeID),
    CONSTRAINT FK_SavedRecipes_userID FOREIGN KEY (userID)
    REFERENCES Users(userID)
    ON DELETE CASCADE,
    CONSTRAINT FK_SavedRecipes_recipeID FOREIGN KEY (recipeID)
    REFERENCES Recipes(recipeID)
    ON DELETE CASCADE
);

# Creates UserFollowers table. ON DELETE CASCADE allows for the user_id to be removed from followers and who they follow.
DROP TABLE IF EXISTS UserFollowers;
CREATE TABLE UserFollowers (
    userFollowerID int NOT NULL AUTO_INCREMENT,
    followerUserID int,
    followedUserID int,
    PRIMARY KEY (userFollowerID),
    CONSTRAINT FK_UserFollowers_followerUserID FOREIGN KEY (followerUserID)
    REFERENCES Users(userID)
    ON DELETE CASCADE,
    CONSTRAINT FK_UserFollowers_followedUserID FOREIGN KEY (followedUserID)
    REFERENCES Users(userID)
    ON DELETE CASCADE
);

#Insert sample data into Users
INSERT INTO Users (firstName, lastName, email)
VALUES ('Michael', 'Sams', 'michaelsams247@gmail.com'),
('John','Doe','johndoe@gmail.com'),
('Kenny','Powers','kennypowers@gmail.com'),
('Leslie','Knope','leslieknope@gmail.com'),
('Tom','Haverford','thaverford@gmail.com');

#Insert sample data into Recipes
INSERT INTO Recipes (userID, name, mealType, duration, servingSize, directions)
VALUES (1, 'Honey Garlic Pork Chops', 'Dinner', 45, 4, 'Step 1: Season pork chops with salt, pepper, and garlic powder. Step 2: In a pan on medium heat, add oil and cook each side of the pork chops for 4–5 minutes, or until done. Then remove pork chops from pan. Step 3: In that same pan add in butter and garlic and sauté until fragrant. Step 4: Turn up heat to medium high and add in honey, apple cider vinegar and water. Step 5: Once the sauce has thickened, add back in the pork chops and baste the sauce over the pork chops for 2 minutes. Step 6: Remove from heat and serve.'),
(2, 'Roasted Potatoes', 'Side', 45, 4, 'Step 1: Cut mini potatoes into 1/4ths. Step 2: Cover potatoes in olive oil. Combine seasoning in bowl and then toss in the potatoes. Step 3: Bake in oven at 425 degree F for 30-40 minutes.'),
(4, 'Matcha Waffles', 'Breakfast', 30, 8, 'Step 1: Beat eggs in a large mixing bowl, then gradually add the rest of the ingredients in order except for the chocolate chips. Step 2: Heat the waffle iron. Pour batter in the iron and sprinkle several chocolate chips on top, spoon a little more batter on top to cover the chocolate chips. Cover the lid and bake for 2.5 minutes. Step 3: Remove the waffle from the iron and cool on a rack for at least 1 minute.'),
(4, 'Double Chocolate Chip Cookies', 'Dessert', 40, 18, 'Step 1: Preheat an oven to 350 degrees F. Line parchment paper on a baking sheet. Step 2: In a large mixing bowl, stir butter and both sugars until combined. Add the egg and stir. Step 3: Add vanilla, salt, cocoa powder, flour, and baking soda to the bowl and stir until combined. Step 4: Fold in chocolate chips. Step 5: Use a cookie scoop to place the dough on the baking sheet, then bake for 12 minutes.');

#Insert sample data into Ingredients
INSERT INTO Ingredients (name)
VALUES ('Honey'),
('Pork Chops'),
('Garlic'),
('Salt'),
('Pepper'),
('Apple Cider Vinegar'),
('Garlic Powder'),
('Unsalted Butter'),
('Olive Oil'),
('Onion Powder'),
('Paprika'),
('Italian Seasoning'),
('Baby Potatos'),
('Water'),
('Egg'),
('Buttermilk'),
('Milk'),
('Rolled Oats'),
('White Sugar'),
('Brown Sugar'),
('Almond Flour'),
('All-Purpose Flour'),
('Flaxseed Meal'),
('Chia Seeds'),
('Hemp Seeds'),
('Matcha Powder'),
('Baking Soda'),
('Baking Powder'),
('Chocolate Chips'),
('Vanilla Extract'),
('Unsweetened Cocoa Powder');

#Insert sample data into Reviews
INSERT INTO Reviews (recipeID, userID, date, rating, comment)
VALUES ((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT userID FROM Users where email = 'michaelsams247@gmail.com'), '2024-06-07', 3, 'So tasty!'),
((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT userID FROM Users where email = 'johndoe@gmail.com'), '2024-07-07', 4, 'My family and I loved this dish! So flavorful.'),
((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT userID FROM Users where email = 'kennypowers@gmail.com'), '2024-07-11', 1, 'Horrible. If I could rate it less than a 1, I would.'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT userID FROM Users where email = 'thaverford@gmail.com'), '2024-07-13', 5, 'Best waffles ever!!!'),
((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT userID FROM Users where email = 'thaverford@gmail.com'), '2024-07-14', 2, NULL);

#Insert sample data into UserFollowers
INSERT INTO  UserFollowers (followerUserID, followedUserID)
VALUES ((SELECT userID FROM Users where email = 'michaelsams247@gmail.com'), (SELECT userID FROM Users where email = 'johndoe@gmail.com')),
((SELECT userID FROM Users where email = 'michaelsams247@gmail.com'), (SELECT userID FROM Users where email = 'kennypowers@gmail.com')),
((SELECT userID FROM Users where email = 'johndoe@gmail.com'), (SELECT userID FROM Users where email = 'kennypowers@gmail.com')),
((SELECT userID FROM Users where email = 'leslieknope@gmail.com'), (SELECT userID FROM Users where email = 'michaelsams247@gmail.com')),
((SELECT userID FROM Users where email = 'leslieknope@gmail.com'), (SELECT userID FROM Users where email = 'thaverford@gmail.com'));

#Insert sample data into SavedRecipes
INSERT INTO SavedRecipes (userID, recipeID)
VALUES ((SELECT userID FROM Users where email = 'michaelsams247@gmail.com'),(SELECT recipeID FROM Recipes where name = 'Roasted Potatoes')),
((SELECT userID FROM Users where email = 'johndoe@gmail.com'), (SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops')),
((SELECT userID FROM Users where email = 'kennypowers@gmail.com'), (SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops')),
((SELECT userID FROM Users where email = 'leslieknope@gmail.com'), (SELECT recipeID FROM Recipes where name = 'Roasted Potatoes')),
((SELECT userID FROM Users where email = 'leslieknope@gmail.com'), (SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'));

#Insert sample data into RecipeIngredients
INSERT INTO RecipeIngredients (recipeID, ingredientID, quantity, unit)
VALUES ((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT ingredientID FROM Ingredients WHERE name = 'Honey'), '1/4', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT ingredientID FROM Ingredients WHERE name = 'Pork Chops'), '4', NULL),
((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT ingredientID FROM Ingredients WHERE name = 'Garlic'), '8', 'Cloves'),
((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT ingredientID FROM Ingredients WHERE name = 'Salt'), '1', 'To season'),
((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT ingredientID FROM Ingredients WHERE name = 'Pepper'), '1', 'To season'),
((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT ingredientID FROM Ingredients WHERE name = 'Apple Cider Vinegar'), '2', 'Tbsp'),
((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT ingredientID FROM Ingredients WHERE name = 'Garlic Powder'), '1', 'To season'),
((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT ingredientID FROM Ingredients WHERE name = 'Unsalted Butter'), '1', 'Tbsp'),
((SELECT recipeID FROM Recipes where name = 'Honey Garlic Pork Chops'), (SELECT ingredientID FROM Ingredients WHERE name = 'Olive Oil'), '2', 'Tbsp'),
((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT ingredientID FROM Ingredients WHERE name = 'Salt'), '1', 'Tsp'),
((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT ingredientID FROM Ingredients WHERE name = 'Pepper'), '1', 'Tsp'),
((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT ingredientID FROM Ingredients WHERE name = 'Garlic Powder'), '2', 'Tsp'),
((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT ingredientID FROM Ingredients WHERE name = 'Olive Oil'), '1', 'Tbsp'),
((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT ingredientID FROM Ingredients WHERE name = 'Onion Powder'), '1', 'Tsp'),
((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT ingredientID FROM Ingredients WHERE name = 'Paprika'), '2', 'Tsp'),
((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT ingredientID FROM Ingredients WHERE name = 'Italian Seasoning'), '1', 'Tbsp'),
((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT ingredientID FROM Ingredients WHERE name = 'Baby Potatos'), '1 1/2', 'lb'),
((SELECT recipeID FROM Recipes where name = 'Roasted Potatoes'), (SELECT ingredientID FROM Ingredients WHERE name = 'Water'), '1/4', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Egg'), '2', 'Whole'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Buttermilk'), '1', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Milk'), '3/4', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Rolled Oats'), '3/4', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'White Sugar'), '2', 'Tbsp'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Almond Flour'), '1/2', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Flaxseed Meal'), '1/4', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Chia Seeds'), '1', 'Tbsp'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Hemp Seeds'), '2', 'Tbsp'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Matcha Powder'), '1', 'Tbsp'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Olive Oil'), '2', 'Tbsp'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'All-Purpose Flour'), '1/2', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Baking Soda'), '1/2', 'Tsp'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Baking Powder'), '1 1/2', 'Tsp'),
((SELECT recipeID FROM Recipes where name = 'Matcha Waffles'), (SELECT ingredientID FROM Ingredients WHERE name = 'Chocolate Chips'), '1/3', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'), (SELECT ingredientID FROM Ingredients WHERE name = 'Unsalted Butter'), '1', 'Stick'),
((SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'), (SELECT ingredientID FROM Ingredients WHERE name = 'White Sugar'), '1/3', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'), (SELECT ingredientID FROM Ingredients WHERE name = 'Brown Sugar'), '1/3', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'), (SELECT ingredientID FROM Ingredients WHERE name = 'Egg'), '1', 'Whole'),
((SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'), (SELECT ingredientID FROM Ingredients WHERE name = 'Vanilla Extract'), '1', 'Tsp'),
((SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'), (SELECT ingredientID FROM Ingredients WHERE name = 'Salt'), '1', 'Pinch'),
((SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'), (SELECT ingredientID FROM Ingredients WHERE name = 'Unsweetened Cocoa Powder'), '1/4', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'), (SELECT ingredientID FROM Ingredients WHERE name = 'All-Purpose Flour'), '1 1/4', 'Cup'),
((SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'), (SELECT ingredientID FROM Ingredients WHERE name = 'Baking Soda'), '1/2', 'Tsp'),
((SELECT recipeID FROM Recipes where name = 'Double Chocolate Chip Cookies'), (SELECT ingredientID FROM Ingredients WHERE name = 'Chocolate Chips'), '1 1/8', 'Cup');

SET FOREIGN_KEY_CHECKS=1;
COMMIT;