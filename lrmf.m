function [ A,B ] = lrmf( Y, alg, rank, varargin )
%LRMF Summary of this function goes here
%   Detailed explanation goes here

%% Set algorithm parameters from input or by using defaults
params = inputParser;
params.addParamValue('tol',1e-4,@isscalar);
params.addParamValue('maxiters',50,@(x) isscalar(x) & x > 0);
%params.addParamValue('init', 'random', @(x) (iscell(x) || ismember(x,{'random','nvecs'})));
params.addParamValue('printitn',1,@isscalar);
params.parse(varargin{1}{:});

%%
if strcmp(alg, 'hals')
    [A,B] = nmf_fast_hals(Y, rank, params.Results.tol, params.Results.maxiters, 1);
elseif strcmp(alg, 'als')
    [A,B] = nmf_als(Y, rank, params.Results.tol, params.Results.maxiters, 1);
elseif strcmp(alg, 'svd')
    [U,S,V] = svd(Y, 'econ');
    U = U*S;
    A = U(:,1:rank);
    B = V(:,1:rank)';
elseif strcmp(alg, 'left_svd_qr')
    [U, s] = left_svd_qr(Y);
    A = U(:,1:rank);
    B = 0;
elseif strcmp(alg, 'xray')
    Yt = Y';
    [~, R] =qr(Yt,0);    
    [RA,XR,res,K] = Xray(R,rank,2);
  %  [RA,XR,res,K] = SPA(R,rank,0);
  %  [RA,K] = SimplexMax_method(R,rank);
     AR = R(:,K);
     X = fast_hals_inner(AR,R,rand(size(AR,2),size(R,2)),1e-5,200);
     A = X'; B = Yt(:,K)';
end
    
end

