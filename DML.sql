-- All variables that will have data from the backend programming language are denoted with a colon :

/*
    SELECT queries
*/

-- get all relationships for followers in the User Followers page

SELECT 
    UserFollowers.userFollowerID,
    CONCAT(follower.firstName, ' ', follower.lastName) AS followerName,
    CONCAT(followed.firstName, ' ', followed.lastName) AS followedName
FROM 
    UserFollowers 
INNER JOIN 
    Users follower ON UserFollowers.followerUserID = follower.userID
INNER JOIN 
    Users followed ON UserFollowers.followedUserID = followed.userID;

-- get all users for the Users page 
SELECT * 
FROM Users

-- get all reviews for the Reviews page 
SELECT 
    Reviews.reviewID,
    Recipes.name AS recipeName,
    CONCAT(Users.firstName, ' ', Users.lastName) AS userName,
    Reviews.date,
    Reviews.rating,
    Reviews.comment
FROM 
    Reviews
INNER JOIN 
    Recipes ON Reviews.recipeID = Recipes.recipeID
INNER JOIN 
    Users ON Reviews.userID = Users.userID;

-- get all saved recipes for the Saved Recipes page 
SELECT 
    SavedRecipes.savedRecipeID,
    CONCAT(Users.firstName, ' ', Users.lastName) AS userName,
    Recipes.name AS recipeName
FROM 
    SavedRecipes
INNER JOIN 
    Users ON SavedRecipes.userID = Users.userID
INNER JOIN 
    Recipes ON SavedRecipes.recipeID = Recipes.recipeID;

-- get all ingredients for the Ingredients page
SELECT *
FROM Ingredients

-- get all recipe ingredients for the Recipe Ingredients page
SELECT 
    RecipeIngredients.recipeIngredientID,
    Recipes.name AS recipeName,
    Ingredients.name AS ingredientName,
    RecipeIngredients.quantity,
    RecipeIngredients.unit
FROM 
    RecipeIngredients
INNER JOIN 
    Recipes ON RecipeIngredients.recipeID = Recipes.recipeID
INNER JOIN 
    Ingredients ON RecipeIngredients.ingredientID = Ingredients.ingredientID;

-- get all recipes for the Recipes page 
SELECT 
    Recipes.recipeID,
    CONCAT(Users.firstName, ' ', Users.lastName) AS userName,
    Recipes.name AS recipeName,
    Recipes.mealType,
    Recipes.duration,
    Recipes.servingSize,
    Recipes.totalCost,
    Recipes.directions
FROM 
    Recipes
INNER JOIN 
    Users ON Recipes.userID = Users.userID;

-- get all ingredient names to dynamically populate a search field, used in a Recipe's page when adding an ingredient to the recipe
SELECT Ingredients.ingredientID, Ingredients.name
FROM Ingredients;

-- get all user names to populate a drop down menu to select a user 
SELECT Users.firstName, Users.lastName
FROM Users;

/*
    INSERT queries 
*/

-- create a new follow relationship between two users 
-- this is a M:N relationship
INSERT INTO UserFollowers (followerUserID, followedUserID)
VALUES (:followerUserID, :followedUserID);

-- create a new user  
INSERT INTO Users (firstName, lastName, email)
VALUES (:firstNameInput, :lastNameInput, :emailInput);

-- create a new review
INSERT INTO Reviews (recipeID, userID, date, rating, comment)
VALUES (:recipeID, :userID, :date, :ratingInput, :commentInput)

-- create a new saved recipe relationship between user and recipe 
-- this is a M:N relationship
INSERT INTO SavedRecipes (userID, recipeID)
VALUES (:userID, :recipeID)

-- create a new ingredient 
INSERT INTO Ingredients (name, cost)
VALUES (:nameInput, :costInput)

-- create a new recipe ingredient relationship  
-- this is a M:N relationship
INSERT INTO RecipeIngredients (recipeID, ingredientID, quantity, unit)
VALUES (:recipeID, :ingredientID, :quantityInput, :unitInput)

-- create a new recipe
INSERT INTO Recipes (userID, name, mealType, duration, servingSize, directions)
VALUES (:userID, :nameInput, :mealTypeInput, :durationInput, :servingSizeInput, :directionsInput);


/*
    UPDATE queries
*/

-- update a user
UPDATE Users
SET firstName = :firstNameInput, lastName = :lastNameInput, email = :emailInput
WHERE userID = :userID;

-- update a review
UPDATE Reviews
SET date = :date, rating = :ratingInput, comment = :commentInput
WHERE reviewID = :reviewID;

-- update a review to have a NULL userID (foreign key)
-- this makes the review anonymous
UPDATE Reviews
SET userID = NULL
WHERE reviewID = :reviewID;

-- update an ingredient
UPDATE Ingredients
SET name = :nameInput, cost = :costInput
WHERE ingredientID = :ingredientID;

-- update a recipe's ingredient 
UPDATE RecipeIngredients
SET quantity = :quantityInput, unit = :unitInput
WHERE recipeIngredientID = :recipeIngredientID;

-- update a recipe
UPDATE Recipes
SET name = :nameInput, 
mealType = :mealTypeInput, 
duration = :durationInput, 
servingSize = :servingSizeInput, 
totalCost = :totalCost, 
directions = :directionsInput
WHERE recipeID = :recipeID;

/*
    DELETE queries
*/

-- delete a follower relationship (unfollow a user)
DELETE FROM UserFollowers
WHERE followerUserID = :followerUserID AND followedUserID = :followedUserID;

-- delete a user 
DELETE FROM Users
WHERE userID = :userID;

-- delete a review
DELETE FROM Reviews
WHERE reviewID = :reviewID;

-- delete a saved recipe relationship (remove a recipe from a user's Cookbook page)
DELETE FROM SavedRecipes
WHERE userID = :userID AND recipeID = :recipeID; 

-- delete an ingredient
DELETE FROM Ingredients
WHERE ingredientID = :ingredientID

-- delete a recipe ingredient
DELETE FROM RecipeIngredients
WHERE recipeIngredientID = :recipeIngredientID;

-- delete a recipe 
DELETE FROM Recipes
WHERE recipeID = :recipeID;





