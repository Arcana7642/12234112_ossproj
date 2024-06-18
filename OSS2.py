import numpy as np
import pandas as pd
from sklearn.cluster import KMeans

ratings = pd.read_csv('ratings.dat', sep='::', names=['UserID', 'MovieID', 'Rating', 'Timestamp'], engine='python')
movies = pd.read_csv('movies.dat', sep='::', names=['MovieID', 'Title', 'Genres'], engine='python', encoding='ISO-8859-1')
users = pd.read_csv('users.dat', sep='::', names=['UserID', 'Gender', 'Age', 'Occupation', 'Zip-code'], engine='python')

max_user_id = ratings['UserID'].max()
max_movie_id = ratings['MovieID'].max()

user_item_matrix = np.zeros((max_user_id, max_movie_id))

for row in ratings.itertuples():
    user_item_matrix[row.UserID - 1, row.MovieID - 1] = row.Rating

kmeans = KMeans(n_clusters=3, random_state=0)
clusters = kmeans.fit_predict(user_item_matrix)

def additive_utilitarian(group):
    return np.sum(group, axis=0)

def average(group):
    return np.mean(group, axis=0)

def simple_count(group):
    return np.sum(group > 0, axis=0)

def approval_voting(group, threshold=4):
    return np.sum(group >= threshold, axis=0)

def borda_count(group):
    ranks = np.argsort(np.argsort(group, axis=1), axis=1)
    return np.sum(ranks, axis=0)

def copeland_rule(group):
    wins = np.zeros(group.shape[1])
    for i in range(group.shape[1]):
        for j in range(group.shape[1]):
            if i != j:
                wins[i] += np.sum(group[:, i] > group[:, j])
    return wins

group_recommendations = {}

def calculate_recommendations_for_group(group):
    return {
        'Additive Utilitarian': additive_utilitarian(group),
        'Average': average(group),
        'Simple Count': simple_count(group),
        'Approval Voting': approval_voting(group),
        'Borda Count': borda_count(group),
        'Copeland Rule': copeland_rule(group)
    }

for i in range(3):
    group = user_item_matrix[clusters == i]
    group_recommendations[f'Group {i+1}'] = calculate_recommendations_for_group(group)

for group, methods in group_recommendations.items():
    print(f"\n{group}:\n")
    for method, scores in methods.items():
        top_10_indices = np.argsort(scores)[-10:][::-1]
        top_10_movies = [movies.iloc[idx]['Title'] for idx in top_10_indices]
        print(f"{method}: {', '.join(top_10_movies)}")
    print("\n")