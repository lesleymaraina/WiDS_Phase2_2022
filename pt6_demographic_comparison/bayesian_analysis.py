"""
date : June 1 2022
author: Lesley M Chapman Hannah
description:
Implement ordered logistic regression on hazarous air particle data from select states that have high and low social demographics
"""

#Import libraries
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import numpy as np
import pandas as pd
from pandas import read_csv
import pymc3 as pm
from pymc3 import plot_posterior
import theano
import theano.tensor as tt
import seaborn as sns
from sklearn.decomposition import NMF
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
import sys
import time
start = time.time()

file = sys.argv[1]
state = sys.argv[2]
df = pd.read_csv(file, sep='\t')

#Bin ozone levels
bins = [0, 0.064, 0.084, 0.104, 0.124, 0.374]
labels = [0,1,2,3,4]
df['ozone_binned'] = pd.cut(df['Max_Value_Ozone'], bins=bins, labels=labels)

#Shuffle rows of the dataframe
df = df.sample(frac=1)

print(state, "ozone bins")
print(df['ozone_binned'].unique())

#Plot distribution of ozone related health outcomes
# Ozone Levels: Good
oz_good = df.loc[df['ozone_binned'] == 0]
n, bins, patches = plt.hist(x=oz_good['Max_Value_Ozone'], bins='auto', color='#0504aa',
                            alpha=0.7, rwidth=0.85)

plt.xlabel('Max_Value_Ozone')
plt.ylabel('Frequency')
plt.title('Ozone Level for 8 Hours (ppm): Good')

plt.savefig(state + '_bin0_dist.png', bbox_inches='tight')
plt.close()

# Ozone Levels: Moderate 
oz_moderate = df.loc[df['ozone_binned'] == 1]
n, bins, patches = plt.hist(x=oz_moderate['Max_Value_Ozone'], bins='auto', color='#0504aa',
                            alpha=0.7, rwidth=0.85)

plt.xlabel('Max_Value_Ozone')
plt.ylabel('Frequency')
plt.title('Ozone Level for 8 Hours (ppm): Moderate')

plt.savefig(state + '_bin1_dist.png', bbox_inches='tight')
plt.close()

# Ozone Levels: Unhealthy_Sensitive 
oz_unh_sens = df.loc[df['ozone_binned'] == 2]
n, bins, patches = plt.hist(x=oz_unh_sens['Max_Value_Ozone'], bins='auto', color='#0504aa',
                            alpha=0.7, rwidth=0.85)

plt.xlabel('Max_Value_Ozone')
plt.ylabel('Frequency')
plt.title('Ozone Level for 8 Hours (ppm): Unhealthy for Sensitive Groups')

plt.savefig(state + '_bin2_dist.png', bbox_inches='tight')
plt.close()

# Ozone Levels: Unhealthy 
oz_unhealthy  = df.loc[df['ozone_binned'] == 3]
n, bins, patches = plt.hist(x=oz_unhealthy['Max_Value_Ozone'], bins='auto', color='#0504aa',
                            alpha=0.7, rwidth=0.85)

plt.xlabel('Max_Value_Ozone')
plt.ylabel('Frequency')
plt.title('Ozone Level for 8 Hours (ppm): Unhealthy')

plt.savefig(state + '_bin3_dist.png', bbox_inches='tight')
plt.close()

# Ozone Levels: Very Unhealthy 
oz_very_unhealthy  = df.loc[df['ozone_binned'] == 4]
n, bins, patches = plt.hist(x=oz_very_unhealthy['Max_Value_Ozone'], bins='auto', color='#0504aa',
                            alpha=0.7, rwidth=0.85)

plt.xlabel('Max_Value_Ozone')
plt.ylabel('Frequency')
plt.title('Ozone Level for 8 Hours (ppm): Very Unhealthy')

plt.savefig(state + '_bin4_dist.png', bbox_inches='tight')
plt.close()

#Create training sets
# Drop descriptive columns (i.e.: date, max ozone)
n = 5 
df = df.sample(n=1000)
df = df.loc[(df!=0).any(axis=1)]
print(df.head(3))
df_hap = df.iloc[:,n:]
df_hap = df_hap.fillna(0)
X = df_hap.drop('ozone_binned', 1)
y = df_hap.filter(items=['ozone_binned'])

train_set_x, test_set_x, train_set_y, test_set_y = train_test_split(X, y, random_state=0, train_size = .75)

#Ordered logistic regression
p = train_set_x.shape[1]

sigma_prior = 1
#train_set_x = train_set_x.to_numpy()
#train_set_y = train_set_y.to_numpy() 


#theano.config.compute_test_value = 'off'
theano.config.compute_test_value = "warn"
train_set_x = train_set_x.to_numpy()
train_set_y = train_set_y.to_numpy() 


X_aug = tt.concatenate((np.ones((train_set_x.shape[0], 1)), train_set_x), axis=1)
#X_aug = tt.concatenate((np.ones((train_set_x.shape[0], 1)), train_set_x), axis=1)
with pm.Model() as model:
    #priors
    mu_beta = pm.Normal('mu_beta', mu=0, sd=2)
    sd_beta = pm.HalfNormal('sd',sd=sigma_prior)
    beta = pm.Normal('beta', mu=0, sd=2, shape=train_set_x.shape[1] + 1)
    #beta = pm.Laplace('beta', mu=mu_beta, b=sd_beta, shape=p)
    #beta = pm.Laplace('beta', mu=mu_beta, b=sd_beta, shape=train_set_x.shape[1] + 1)

    # ASK: How to determine cutpoints
    cutpoints = pm.Normal("cutpoints", mu=np.array([-1,1]), sd=1, shape=2,
                          transform=pm.distributions.transforms.ordered)
    
    #deterministic transformation
    #Basic Idea: keeps track of mu at every iteration
    #lp = pm.Deterministic('lp', pm.math.dot(train_set_x,beta))
    lp = X_aug.dot(beta)

    #likelihood
    y_obs = pm.OrderedLogistic("y_obs", eta=1, cutpoints=cutpoints, observed=train_set_y)

print("trace")
#trace = pm.sample(draws=500, model=model, random_seed=31)
trace = pm.sample(500, model=model)
#trace['HAP'] = list(df_hap)
print("trace done")

print(list(df_hap))

#with pm.Model() as model:
#    #priors
#    mu_beta = pm.Normal('mu_beta', mu=0, sd=2)
#    sd_beta = pm.HalfNormal('sd',sd=sigma_prior)
#    beta = pm.Normal('beta', mu=0, sd=2, shape=train_set_x.shape[1] + 1)
#    #beta = pm.Laplace('beta', mu=mu_beta, b=sd_beta, shape=p)

#    # ASK: How to determine cutpoints
#    cutpoints = pm.Normal("cutpoints", mu=np.array([-1,1]), sd=1, shape=2,
#                          transform=pm.distributions.transforms.ordered)
    
#    #deterministic transformation
#    #Basic Idea: keeps track of mu at every iteration
#    #lp = pm.Deterministic('lp', pm.math.dot(train_set_x,beta))
#    lp = X_aug.dot(beta)
#    #likelihood
#    y_obs = pm.OrderedLogistic("y_obs", eta=lp, cutpoints=cutpoints, observed=train_set_y)


#Evaluate model convergence
pm.traceplot(trace)
fig = plt.gcf()
fig.savefig(state + "_traceplot_model_conv.png") 

#Plot posterior plots
plot_posterior(trace[150:], ref_val=1)
plt.savefig(state + '_posterior_plot.png', bbox_inches='tight')

#Save pm trace table
#print(pm.summary(trace).round(2))
x = pm.summary(trace).round(2)
x['beta'] = x.index
x = x[x['beta'].str.contains("beta\[")]
x['HAP'] = list(df_hap)
x = x.sort_values(by=['mean'], ascending=False)
print(x.head(3))
x.to_csv(state + '_beta_haps.tsv', header=True, sep='\t', index=False)



post_pred_train = pm.sample_posterior_predictive(trace, samples=500, model=model, var_names=["y_obs"])
y_pred_train_df = post_pred_train["y_obs"]
fig=plt.figure(figsize=(15,5))
gs=GridSpec(nrows=1,ncols=2,width_ratios=[1,2]) # Select row and column values: 2 rows, 3 columns

ax0 = fig.add_subplot(gs[0])
ax0.set_title("Y Values")
y_plot = sns.kdeplot(data=pd.DataFrame(y_pred_train_df[:,:5]),ax=ax0)
y_plot.figure.savefig(state + "_posterior_yvalues.png")


