from flask import Flask, render_template, json, redirect
from flask_mysqldb import MySQL
from flask import request
import datetime
import os

app = Flask(__name__)

# Connect to OSU sql server

app.config['MYSQL_HOST'] = 'classmysql.engr.oregonstate.edu'
app.config['MYSQL_USER'] = 'cs340_'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'cs340_'
app.config['MYSQL_CURSORCLASS'] = "DictCursor"

mysql = MySQL(app)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/recipes', methods = ['GET', 'POST'])
def recipes():
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        if 'insert' in request.form:
            cur.execute("SELECT userID FROM Users WHERE firstName = '{}' and lastName = '{}'".format(request.form['dropdown0'].split(' ')[0], request.form['dropdown0'].split(' ')[1]))
            userID = cur.fetchall()[0]['userID']

            insertQuery = "INSERT INTO Recipes (userID, name, mealType, duration, servingSize, totalCost, directions) VALUES ({}, '{}', '{}', '{}', '{}', '{}', '{}')".format(userID, request.form['Name'], request.form['MealType'], request.form['Duration'], request.form['ServingSize'], request.form['TotalCost'], request.form['Directions'])
            cur.execute(insertQuery)
            cur.execute('COMMIT;')  

        elif 'update' in request.form:
            cur.execute("SELECT userID FROM Users WHERE firstName = '{}' and lastName = '{}'".format(request.form['User Name'].split(' ')[0], request.form['User Name'].split(' ')[1]))
            userID = cur.fetchall()[0]['userID']
            updateQuery = "UPDATE Recipes SET userID = {}, name = '{}', mealType = '{}', duration = '{}', servingSize = '{}', totalCost = '{}', directions = '{}' WHERE recipeID = {}".format(userID, request.form['Name'], request.form['MealType'], request.form['Duration'], request.form['ServingSize'], request.form['TotalCost'], request.form['Directions'], request.form['primary_key_value'])
            cur.execute(updateQuery)
            cur.execute('COMMIT;')   

        elif 'delete' in request.form:
            deleteQuery = "DELETE FROM Recipes WHERE recipeID = {}".format(request.form['delete'])
            cur.execute(deleteQuery)
            cur.execute('COMMIT;')

    recipeQuery = "SELECT Recipes.recipeID, CONCAT(Users.firstName,' ', Users.lastName) AS userName, Recipes.name, Recipes.mealType, Recipes.duration, Recipes.servingSize, Recipes.totalCost, Recipes.directions FROM Recipes JOIN Users ON Recipes.userID = Users.userID;"
    cur = mysql.connection.cursor()
    cur.execute(recipeQuery)
    recipes = cur.fetchall()
    
    return render_template('recipes.html', recipes=recipes)

@app.route('/users', methods = ['GET', 'POST'])
def users():
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        if 'insert' in request.form:
            insertQuery = "INSERT INTO Users (firstName, lastName, email) VALUES ('{}', '{}', '{}')".format(request.form['FirstName'], request.form['LastName'], request.form['Email'])
            cur.execute(insertQuery)
            cur.execute('COMMIT;')  

        elif 'update' in request.form:
            updateQuery = "UPDATE Users SET firstName = '{}', lastName = '{}', email = '{}' WHERE userID = {}".format(request.form['FirstName'], request.form['LastName'], request.form['Email'], request.form['primary_key_value'])
            cur.execute(updateQuery)
            cur.execute('COMMIT;')

        elif 'delete' in request.form:
            deleteQuery = "DELETE FROM Users WHERE userID = {}".format(request.form['delete'])
            cur.execute(deleteQuery)
            cur.execute('COMMIT;')

    userQuery = "SELECT Users.userID, Users.firstName, Users.lastName, Users.email FROM Users"
    cur.execute(userQuery)
    users = cur.fetchall()
    
    return render_template('users.html', users=users)

@app.route('/userFollowers', methods= ['GET', 'POST'])
def userFollowers():
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        if 'insert' in request.form:
            cur.execute("SELECT userID FROM Users WHERE firstName = '{}' and lastName = '{}'".format(request.form['dropdown0'].split(' ')[0], request.form['dropdown0'].split(' ')[1]))
            followerID = cur.fetchall()[0]['userID']
            cur.execute("SELECT userID FROM Users WHERE firstName = '{}' and lastName = '{}'".format(request.form['dropdown1'].split(' ')[0], request.form['dropdown1'].split(' ')[1]))
            followedID = cur.fetchall()[0]['userID']

            checkQuery = "SELECT * FROM UserFollowers WHERE followerUserID = {} and followedUserID = {}".format(followerID, followedID)
            cur.execute(checkQuery)

            if followerID == followedID:
                flash_message = "User cannot follow themself"
            elif cur.fetchall() == ():
                insertQuery = "INSERT INTO UserFollowers (followerUserID, followedUserID) VALUES ({}, {})".format(followerID, followedID)
                cur.execute(insertQuery)
                cur.execute('COMMIT;')  
            else:
                flash_message = "Cannot follow. Already following"

        elif 'update' in request.form:
            cur.execute("SELECT userID FROM Users WHERE firstName = '{}' and lastName = '{}'".format(request.form['FollowerUser Name'].split(' ')[0], request.form['FollowerUser Name'].split(' ')[1]))
            followerID = cur.fetchall()[0]['userID']
            cur.execute("SELECT userID FROM Users WHERE firstName = '{}' and lastName = '{}'".format(request.form['FollowedUser Name'].split(' ')[0], request.form['FollowedUser Name'].split(' ')[1]))
            followedID = cur.fetchall()[0]['userID']
            if followerID == followedID:
                flash_message = "User cannot follow themself"
            elif cur.fetchall() == ():
                updateQuery = "UPDATE UserFollowers SET followerUserID = {}, followedUserID = {} WHERE userFollowerID = {}".format(followerID, followedID, request.form['primary_key_value'])
                cur.execute(updateQuery)
                cur.execute('COMMIT;')  
            else:
                flash_message = "Cannot follow. Already following"

        elif 'delete' in request.form:
            deleteQuery = "DELETE FROM UserFollowers WHERE userFollowerID = {}".format(request.form['delete'])
            cur.execute(deleteQuery)
            cur.execute('COMMIT;')

    userFollowersQuery = "SELECT UserFollowers.userFollowerID, CONCAT(follower.firstName,' ', follower.lastName) AS followerName, CONCAT(followed.firstName,' ', followed.lastName) AS followedName FROM UserFollowers JOIN Users AS follower ON UserFollowers.followerUserID = follower.userID JOIN Users AS followed ON UserFollowers.followedUserID = followed.userID;"
    cur.execute(userFollowersQuery)
    userFollowers = cur.fetchall()

    return render_template('userFollowers.html', userFollowers=userFollowers)

@app.route('/ingredients', methods= ['GET', 'POST'])
def ingredients():
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        if 'insert' in request.form:
            cur.execute("INSERT INTO Ingredients (name, cost) VALUES ('{}', '{}')".format(request.form['Name'], request.form['Cost']))
            cur.execute('COMMIT;')  

        elif 'update' in request.form:
            cur.execute("UPDATE Ingredients SET name = '{}', cost = {} WHERE ingredientID = {}".format(request.form['Name'], request.form['Cost'], request.form['primary_key_value']))
            cur.execute('COMMIT;')

    ingredients = ({'ingredientID': 1, 'name': 'Honey', 'cost': None}, {'ingredientID': 2, 'name': 'Pork Chops', 'cost': None}, {'ingredientID': 3, 'name': 'Garlic', 'cost': None}, {'ingredientID': 4, 'name': 'Salt', 'cost': None}, {'ingredientID': 5, 'name': 'Pepper', 'cost': None}, {'ingredientID': 6, 'name': 'Apple Cider Vinegar', 'cost': None}, {'ingredientID': 7, 'name': 'Garlic Powder', 'cost': None}, {'ingredientID': 8, 'name': 'Unsalted Butter', 'cost': None}, {'ingredientID': 9, 'name': 'Olive Oil', 'cost': None}, {'ingredientID': 10, 'name': 'Onion Powder', 'cost': None}, {'ingredientID': 11, 'name': 'Paprika', 'cost': None}, {'ingredientID': 12, 'name': 'Italian Seasoning', 'cost': None}, {'ingredientID': 13, 'name': 'Baby Potatos', 'cost': None}, {'ingredientID': 14, 'name': 'Water', 'cost': None}, {'ingredientID': 15, 'name': 'Egg', 'cost': None}, {'ingredientID': 16, 'name': 'Buttermilk', 'cost': None}, {'ingredientID': 17, 'name': 'Milk', 'cost': None}, {'ingredientID': 18, 'name': 'Rolled Oats', 'cost': None}, {'ingredientID': 19, 'name': 'White Sugar', 'cost': None}, {'ingredientID': 20, 'name': 'Brown Sugar', 'cost': None}, {'ingredientID': 21, 'name': 'Almond Flour', 'cost': None}, {'ingredientID': 22, 'name': 'All-Purpose Flour', 'cost': None}, {'ingredientID': 23, 'name': 'Flaxseed Meal', 'cost': None}, {'ingredientID': 24, 'name': 'Chia Seeds', 'cost': None}, {'ingredientID': 25, 'name': 'Hemp Seeds', 'cost': None}, {'ingredientID': 26, 'name': 'Matcha Powder', 'cost': None}, {'ingredientID': 27, 'name': 'Baking Soda', 'cost': None}, {'ingredientID': 28, 'name': 'Baking Powder', 'cost': None}, {'ingredientID': 29, 'name': 'Chocolate Chips', 'cost': None}, {'ingredientID': 30, 'name': 'Vanilla Extract', 'cost': None}, {'ingredientID': 31, 'name': 'Unsweetened Cocoa Powder', 'cost': None})
    return render_template('ingredients.html', ingredients=ingredients)

@app.route('/reviews', methods= ['GET', 'POST'])
def reviews():
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        if 'insert' in request.form:
            recipeIDQuery = "SELECT recipeID FROM Recipes WHERE name = '{}'".format(request.form['dropdown0'])
            cur.execute(recipeIDQuery)
            recipeID = cur.fetchall()[0]['recipeID']
            if request.form['dropdown1'] != 'None' and request.form['dropdown1'] is not None:
                cur.execute("SELECT userID FROM Users WHERE firstName = '{}' and lastName = '{}'".format(request.form['dropdown1'].split(' ')[0], request.form['dropdown1'].split(' ')[1]))
                userID = cur.fetchall()[0]['userID']
                insertQuery = "INSERT INTO Reviews (recipeID, userID, date, rating, comment) VALUES ({}, {}, '{}', {}, '{}')".format(recipeID, userID, request.form['Date'], request.form['Rating'], request.form['Comment'])
            else:
                insertQuery = "INSERT INTO Reviews (recipeID, userID, date, rating, comment) VALUES ({}, NULL, '{}', {}, '{}')".format(recipeID, request.form['Date'], request.form['Rating'], request.form['Comment'])
            cur.execute(insertQuery)
            cur.execute('COMMIT;')  

        elif 'update' in request.form:
            
            recipeIDQuery = "SELECT recipeID FROM Recipes WHERE name = '{}'".format(request.form['Recipe Name'])
            cur.execute(recipeIDQuery)
            recipeID = cur.fetchall()[0]['recipeID']
            if request.form['User Name'] != 'None' and request.form['User Name']  is not None:
                cur.execute("SELECT userID FROM Users WHERE firstName = '{}' and lastName = '{}'".format(request.form['User Name'].split(' ')[0], request.form['User Name'].split(' ')[1]))
                userID = cur.fetchall()[0]['userID']
                updateQuery = "UPDATE Reviews SET recipeID = {}, userID = {}, date = '{}', rating = {}, comment = '{}' WHERE reviewID = {}".format(recipeID, userID, request.form['Date'], request.form['Rating'], request.form['Comment'], request.form['primary_key_value'])
            else:
                updateQuery = "UPDATE Reviews SET recipeID = {}, userID = NULL, date = '{}', rating = {}, comment = '{}' WHERE reviewID = {}".format(recipeID, request.form['Date'], request.form['Rating'], request.form['Comment'], request.form['primary_key_value'])
            cur.execute(updateQuery)
            cur.execute('COMMIT;')  

        elif 'delete' in request.form:
            deleteQuery = "DELETE FROM Reviews WHERE reviewID = {}".format(request.form['delete'])
            cur.execute(deleteQuery)
            cur.execute('COMMIT;')

    reviewQuery = "SELECT Reviews.reviewID, Recipes.name as recipeName, CONCAT(Users.firstName,' ', Users.lastName) AS userName, Reviews.date, Reviews.rating, Reviews.comment FROM Reviews JOIN Recipes ON Reviews.recipeID = Recipes.recipeID JOIN Users ON Reviews.userID = Users.userID;"
    cur = mysql.connection.cursor()
    cur.execute(reviewQuery)
    reviews = cur.fetchall()
    reviewQuery = "SELECT Reviews.reviewID, Recipes.name as recipeName, Reviews.userID AS userName, Reviews.date, Reviews.rating, Reviews.comment FROM Reviews JOIN Recipes ON Reviews.recipeID = Recipes.recipeID WHERE Reviews.userID IS NULL;"
    cur = mysql.connection.cursor()
    cur.execute(reviewQuery)
    reviews += cur.fetchall()

    return render_template('reviews.html', reviews=reviews)

@app.route('/savedRecipes', methods= ['GET', 'POST'])
def savedRecipes():
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        if 'insert' in request.form:
            cur.execute("SELECT userID FROM Users WHERE firstName = '{}' and lastName = '{}'".format(request.form['dropdown0'].split(' ')[0], request.form['dropdown0'].split(' ')[1]))
            userID = cur.fetchall()[0]['userID']
            cur.execute("SELECT recipeID FROM Recipes WHERE name = '{}'".format(request.form['dropdown1']))
            recipeID = cur.fetchall()[0]['recipeID']
            cur.execute("INSERT INTO SavedRecipes (userId, recipeID) VALUES ({}, {})".format(userID, recipeID))
            cur.execute('COMMIT;')  

        elif 'update' in request.form: 
            cur.execute("SELECT userID FROM Users WHERE firstName = '{}' and lastName = '{}'".format(request.form['User Name'].split(' ')[0], request.form['User Name'].split(' ')[1]))
            userID = cur.fetchall()[0]['userID']
            cur.execute("SELECT recipeID FROM Recipes WHERE name = '{}'".format(request.form['Recipe Name']))
            recipeID = cur.fetchall()[0]['recipeID']
            cur.execute("UPDATE SavedRecipes SET userID = {}, recipeID = {} WHERE savedRecipeID = {}".format(userID, recipeID, request.form['primary_key_value']))
            cur.execute('COMMIT;')  

        elif 'delete' in request.form:
            deleteQuery = "DELETE FROM SavedRecipes WHERE savedRecipeID = {}".format(request.form['delete'])
            cur.execute(deleteQuery)
            cur.execute('COMMIT;')

    savedRecipesQuery = "SELECT SavedRecipes.savedRecipeID, CONCAT(Users.firstName,' ', Users.lastName) AS userName, Recipes.name as recipeName FROM SavedRecipes JOIN Recipes ON SavedRecipes.recipeID = Recipes.recipeID JOIN Users ON SavedRecipes.userID = Users.userID;"
    cur = mysql.connection.cursor()
    cur.execute(savedRecipesQuery)
    savedRecipes = cur.fetchall()
    
    return render_template('savedRecipes.html', savedRecipes=savedRecipes)

@app.route('/recipeIngredients', methods= ['GET', 'POST'])
def recipeIngredients():
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        if 'insert' in request.form:
            cur.execute("SELECT recipeID FROM Recipes WHERE name = '{}'".format(request.form['dropdown0']))
            recipeID = cur.fetchall()[0]['recipeID']
            cur.execute("SELECT ingredientID FROM Ingredients WHERE name = '{}'".format(request.form['dropdown1']))
            ingredientID = cur.fetchall()[0]['ingredientID']
            cur.execute("INSERT INTO RecipeIngredients (recipeID, ingredientID, quantity, unit) VALUES ({}, {}, '{}', '{}')".format(recipeID, ingredientID, request.form['Quantity'], request.form['Unit']))
            cur.execute('COMMIT;')

        elif 'update' in request.form:
            cur.execute("SELECT recipeID FROM Recipes WHERE name = '{}'".format(request.form['Recipe Name']))
            recipeID = cur.fetchall()[0]['recipeID']
            cur.execute("SELECT ingredientID FROM Ingredients WHERE name = '{}'".format(request.form['Ingredient Name']))
            ingredientID = cur.fetchall()[0]['ingredientID']
            cur.execute("UPDATE RecipeIngredients SET recipeID = {}, ingredientID = {}, quantity = '{}', unit= '{}' WHERE recipeIngredientID = {}".format(recipeID, ingredientID, request.form['Quantity'], request.form['Unit'], request.form['primary_key_value']))
            cur.execute('COMMIT;')  

        elif 'delete' in request.form:
            deleteQuery = "DELETE FROM RecipeIngredients WHERE recipeIngredientID = {}".format(request.form['delete'])
            cur.execute(deleteQuery)
            cur.execute('COMMIT;')

    recipeIngredientsQuery = "SELECT RecipeIngredients.recipeIngredientID, Recipes.name AS recipeName, Ingredients.name AS ingredientName, RecipeIngredients.quantity, RecipeIngredients.unit FROM RecipeIngredients LEFT JOIN Recipes ON RecipeIngredients.recipeID = Recipes.recipeID LEFT JOIN Ingredients ON RecipeIngredients.ingredientID = Ingredients.ingredientID;"
    cur = mysql.connection.cursor()
    cur.execute(recipeIngredientsQuery)
    recipeIngredients = cur.fetchall()
    
    return render_template('recipeIngredients.html', recipeIngredients=recipeIngredients)

@app.route('/insert/<table>', methods = ['GET', 'POST'])
def insert(table):
    data = {'table': table}
    
    cur = mysql.connection.cursor()
    cur.execute("DESCRIBE {};".format(table))
    tableData = cur.fetchall()
    data['needFields'] = 0
    for element in tableData:
        # Checks if attribute is not the primary key for the table
        if element['Field'][:-2].lower() + 's' != table.lower():
            # Checks if the attribute is a key and if its not UserFollowers
            if 'ID' in element['Field'] and 'follow' not in element['Field']:
                # Gets data from database and populates the data dictionary for dropdown values.
                neededTable = chr(ord(element['Field'][0]) - 32) + element['Field'][1:-2] + 's'
                if neededTable == 'Users':
                    query = "SELECT {} FROM {}".format("CONCAT(Users.firstName,' ', Users.lastName) AS 'UserName'", neededTable)
                else:
                    query = "SELECT {} FROM {}".format('name', neededTable)
                cur.execute(query)
                names = cur.fetchall()
                name = list(names[0].keys())[0]
                data['dropdown{}'.format(str(data['needFields']))] = [names[index][name] for index in range(len(names))]
                data['Field{}'.format(str(data['needFields']))] = chr(ord(element['Field'][0])-32) + element['Field'][1:-2] + ' Name'
           # Checks if the attribute is a key (the only key it can be in UserFollowers)
            elif 'ID' in element['Field']:
                # Gets data from User table and populates the data dictionary for dropdown values.
                cur.execute("SELECT CONCAT(Users.firstName,' ', Users.lastName) AS 'UserName' FROM Users")
                names = cur.fetchall()
                data['dropdown{}'.format(str(data['needFields']))] = [names[index]['UserName'] for index in range(len(names))]
                data['Field{}'.format(str(data['needFields']))] = chr(ord(element['Field'][0])-32) + element['Field'][1:-2] + ' Name'
            else:
                # Populates data dictionary with the table attribute names that don't have dropdown values.
                data['Field{}'.format(str(data['needFields']))] = chr(ord(element['Field'][0])-32) + element['Field'][1:]
            data['needFields'] += 1   
    
    return render_template('insert.html', data=data)

@app.route('/edit/<table>', methods =['GET', 'POST'])
def edit(table):
    rowQuery = 'SELECT * FROM {} WHERE {} = {}'.format(table, chr(ord(table[0]) + 32) + table[1:-1] + 'ID', int(request.form['editRow']))
    cur = mysql.connection.cursor()
    cur.execute(rowQuery)
    tableData = cur.fetchall()[0]
    data = {'needFields': 0}
    
    for attribute in tableData:
        # Checks if attribute is not the primary key for the table
        if attribute[:-2].lower() + 's' != table.lower():
            # Checks if the attribute is a key and if its not UserFollowers
            if 'ID' in attribute and 'follow' not in attribute:
                # Gets data from database and populates the data dictionary for dropdown values.
                neededTable = chr(ord(attribute[0]) - 32) + attribute[1:-2] + 's'
                if neededTable == 'Users':
                    query = "SELECT {}, userID FROM {}".format("CONCAT(Users.firstName,' ', Users.lastName) AS 'UserName'", neededTable)
                    data['Field{}'.format(str(data['needFields']))] = 'User Name'
                else:
                    query = "SELECT {}, {} FROM {}".format('name', attribute, neededTable)
                    data['Field{}'.format(str(data['needFields']))] = chr(ord(attribute[0])-32) + attribute[1:-2] + ' Name'

                cur.execute(query)
                names = cur.fetchall()
                data['dropdown{}'.format(str(data['needFields']))] = []
                for element in range(0,len(names)):
                    if tableData[attribute] == names[element][list(names[element].keys())[1]]:
                        data['dropdown{}selected'.format(str(data['needFields']))] =  names[element][list(names[element].keys())[0]]
                    else:
                        data['dropdown{}'.format(str(data['needFields']))].append(names[element][list(names[element].keys())[0]])
                data['Field{}'.format(str(data['needFields']))] = chr(ord(attribute[0])-32) + attribute[1:-2] + ' Name'   
            
            # Checks if the attribute is a key (the only table it can be is UserFollowers)
            elif 'ID' in attribute:
                # Gets data from Users table and populates the data dictionary for dropdown values.
                cur.execute("SELECT CONCAT(Users.firstName,' ', Users.lastName) AS 'UserName', userID  FROM Users")
                names = cur.fetchall()
                data['dropdown{}'.format(str(data['needFields']))] = []
                for element in range(0,len(names)):
                    if tableData[attribute] == names[element][list(names[element].keys())[1]]:
                        data['dropdown{}selected'.format(str(data['needFields']))] =  names[element][list(names[element].keys())[0]]
                    else:
                        data['dropdown{}'.format(str(data['needFields']))].append(names[element][list(names[element].keys())[0]])
                data['Field{}'.format(str(data['needFields']))] = chr(ord(attribute[0])-32) + attribute[1:-2] + ' Name'    
            else:
                # Populates data dictionary with the table attribute names and values for attribute that don't have dropdown values.
                data['Field{}'.format(str(data['needFields']))] = chr(ord(attribute[0])-32) + attribute[1:]
                data['Value{}'.format(str(data['needFields']))] = tableData[attribute]
            data['needFields'] += 1

    data['table'] = table
    data['primary_key_name'] = chr(ord(table[0]) + 32) + table[1:-1] + 'ID'
    data['primary_key_value'] = int(request.form['editRow'])
    return render_template('edit.html', data=data)


# Listener
if __name__ == "__main__":

    app.run(port=62472, debug=True)
