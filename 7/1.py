from pymongo import MongoClient
client = MongoClient("mongodb://localhost:27017/")
db = client["university"]
db.students.drop()
db.courses.drop()
students = [
    { "_id": 1, "name": "Alice", "age": 22, "major": "Computer Science", "gpa": 3.8 },
    { "_id": 2, "name": "Bob", "age": 23, "major": "Mathematics", "gpa": 3.6 },
    { "_id": 3, "name": "Charlie", "age": 24, "major": "Physics", "gpa": 3.2 },
    { "_id": 4, "name": "David", "age": 21, "major": "Computer Science", "gpa": 3.9 },
    { "_id": 5, "name": "Emma", "age": 22, "major": "Mathematics", "gpa": 3.7 }
]
db.students.insert_many(students)
courses = [
    {
        "_id": 101,
        "course_name": "Math 101",
        "department": "Mathematics",
        "students": [
            { "student_id": 2, "grade": 85 },
            { "student_id": 5, "grade": 92 }
        ]
    },
    {
        "_id": 102,
        "course_name": "Physics 101",
        "department": "Physics",
        "students": [
            { "student_id": 3, "grade": 78 },
            { "student_id": 1, "grade": 88 }
        ]
    },
    {
        "_id": 103,
        "course_name": "CS 101",
        "department": "Computer Science",
        "students": [
            { "student_id": 1, "grade": 95 },
            { "student_id": 4, "grade": 89 }
        ]
    }
]
db.courses.insert_many(courses)
math_students = db.students.find({"major": "Mathematics"})
for student in math_students:
    print(student)
print("=======================")
db.students.update_one({"name": "Charlie"}, {"$set": {"gpa": 3.9}})
db.courses.delete_one({"course_name": "Physics 101"})
high_gpa_students = db.students.find({"gpa": {"$gt": 3.6}})
for student in high_gpa_students:
    print(student)
print("=======================")
pipeline = [
    {"$group": {"_id": "$major", "average_gpa": {"$avg": "$gpa"}}}
]
average_gpa_by_major = db.students.aggregate(pipeline)
for result in average_gpa_by_major:
    print(result)
print("=======================")
db.students.create_index("gpa")
students_name_major = db.students.find({}, {"name": 1, "major": 1, "_id": 0})
for student in students_name_major:
    print(student)
print("=======================")
cs_students = db.courses.find_one({"course_name": "CS 101"})
high_grade_students = [student for student in cs_students["students"] if student["grade"] > 90]
print(high_grade_students)
print("=======================")
db.courses.update_one(
    {"course_name": "Math 101", "students.student_id": 2},
    {"$set": {"students.$.grade": 88}}
)
