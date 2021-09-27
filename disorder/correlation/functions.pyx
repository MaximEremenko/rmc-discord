#cython: boundscheck=False, wraparound=False, language_level=3

import numpy as np
cimport numpy as np

from cython.parallel import prange

cimport cython

from libc.math cimport sqrt, fabs

cdef double iszero(double a) nogil:
    
    cdef double atol = 1e-08
    
    return fabs(a) <= atol

def vector_correlation(double [::1] Sx,
                       double [::1] Sy,
                       double [::1] Sz,
                       signed long long [::1] counts,
                       signed long long [::1] search,
                       long long [:,::1] coordinate):
    
    cdef Py_ssize_t N = counts.shape[0]
    
    S_corr_np = np.zeros(N+1)
    S_corr_np[N] = 1
    
    cdef double [::1] S_corr = S_corr_np

    cdef Py_ssize_t r, s, i, j
    
    cdef double U, V
    
    cdef Py_ssize_t count
    
    for r in range(N):
        
        count = counts[r]

        for s in range(search[r],search[r+1]):
            
            i, j = coordinate[s,0], coordinate[s,1]
            
            U = sqrt(Sx[i]*Sx[i]+Sy[i]*Sy[i]+Sz[i]*Sz[i])
            V = sqrt(Sx[j]*Sx[j]+Sy[j]*Sy[j]+Sz[j]*Sz[j])
                        
            if not (iszero(U) or iszero(V)):
                S_corr[r] += (Sx[i]*Sx[j]+Sy[i]*Sy[j]+Sz[i]*Sz[j])/U/V
            else:
                count -= 1
                
        if (count > 0):
            S_corr[r] /= count
        else:
            S_corr[r] = 0
            
    return S_corr_np
                        
def vector_average(double [::1] Sx,
                   double [::1] Sy,
                   double [::1] Sz,
                   signed long long [::1] counts,
                   signed long long [::1] search,
                   long long [:,::1] coordinate):
    
    cdef Py_ssize_t N = counts.shape[0]
    
    S_corr_np = np.zeros(N+1)
    S_corr_np[N] = 1
    
    cdef double [::1] S_corr = S_corr_np
    
    cdef Py_ssize_t r, s, i, j
    
    cdef double U, V
    
    cdef double Sx_i, Sy_i, Sz_i
    cdef double Sx_j, Sy_j, Sz_j
    
    cdef Py_ssize_t count

    for r in range(N):
        
        count = counts[r]
        
        Sx_i, Sy_i, Sz_i = 0, 0, 0
        Sx_j, Sy_j, Sz_j = 0, 0, 0
        
        for s in range(search[r],search[r+1]):
            
            i, j = coordinate[s,0], coordinate[s,1]
            
            U = sqrt(Sx[i]*Sx[i]+Sy[i]*Sy[i]+Sz[i]*Sz[i])
            V = sqrt(Sx[j]*Sx[j]+Sy[j]*Sy[j]+Sz[j]*Sz[j])
            
            if not (iszero(U) or iszero(V)):
                Sx_i += Sx[i]/U
                Sy_i += Sy[i]/U
                Sz_i += Sz[i]/U
                
                Sx_j += Sx[j]/V
                Sy_j += Sy[j]/V
                Sz_j += Sz[j]/V
            else:
                count -= 1
                
        if (count > 0):
            S_corr[r] = (Sx_i*Sx_j+Sy_i*Sy_j+Sz_i*Sz_j)/count**2
        else:
            S_corr[r] = 0
            
    return S_corr_np
            
def vector_collinearity(double [::1] Sx,
                        double [::1] Sy,
                        double [::1] Sz,
                        signed long long [::1] counts,
                        signed long long [::1] search,
                        long long [:,::1] coordinate):
    
    cdef Py_ssize_t N = counts.shape[0]
    
    S_coll_np = np.zeros(N+1)
    S_coll_np[N] = 1
    
    cdef double [::1] S_coll = S_coll_np
    
    cdef Py_ssize_t r, s, i, j
    
    cdef double U, V
    
    cdef Py_ssize_t count

    for r in range(N):
        
        count = counts[r]

        for s in range(search[r],search[r+1]):
            
            i, j = coordinate[s,0], coordinate[s,1]
            
            U = Sx[i]*Sx[i]+Sy[i]*Sy[i]+Sz[i]*Sz[i]
            V = Sx[j]*Sx[j]+Sy[j]*Sy[j]+Sz[j]*Sz[j]
            
            if not (iszero(U) or iszero(V)):
                S_coll[r] += (Sx[i]*Sx[j]+Sy[i]*Sy[j]+Sz[i]*Sz[j])**2/U/V
            else:
                count -= 1
                
        if (count > 0):
            S_coll[r] /= count
        else:
            S_coll[r] = 0
            
    return S_coll_np
                      
def scalar_correlation(double [::1] A_r,
                       signed long long [::1] counts,
                       signed long long [::1] search,
                       long long [:,::1] coordinate):
    
    cdef Py_ssize_t N = counts.shape[0]
    
    S_corr_np = np.zeros(N+1)
    S_corr_np[N] = 1
    
    cdef double [::1] S_corr = S_corr_np
    
    cdef Py_ssize_t r, s, i, j
    
    cdef double U, V
    
    cdef Py_ssize_t count

    for r in range(N):
        
        count = counts[r]

        for s in range(search[r],search[r+1]):
            
            i, j = coordinate[s,0], coordinate[s,1]
            
            U = fabs(A_r[i])
            V = fabs(A_r[j])
                                        
            if not (iszero(U) or iszero(V)):
                S_corr[r] += (A_r[i]*A_r[j])/U/V
            else:
                count -= 1
                
        if (count > 0):
            S_corr[r] /= count
        else:
            S_corr[r] = 0
            
    return S_corr_np
            
def scalar_average(double [::1] A_r,
                   signed long long [::1] counts,
                   signed long long [::1] search,
                   long long [:,::1] coordinate):
    
    cdef Py_ssize_t N = counts.shape[0]
    
    S_corr_np = np.zeros(N+1)
    S_corr_np[N] = 1
    
    cdef double [::1] S_corr = S_corr_np
    
    cdef Py_ssize_t r, s, i, j
    
    cdef double U, V
    
    cdef double S_i, S_j
    
    cdef Py_ssize_t count

    for r in range(N):
    
        count = counts[r]
        
        S_i, S_j = 0, 0
        
        for s in range(search[r],search[r+1]):
            
            i, j = coordinate[s,0], coordinate[s,1]
            
            U = fabs(A_r[i])
            V = fabs(A_r[j])
            
            if not (iszero(U) or iszero(V)):   
                S_i += A_r[i]/U            
                S_j += A_r[j]/V
            else:
                count -= 1
        
        if (count > 0):
            S_corr[r] = S_i*S_j/count**2                   
        else:
            S_corr[r] = 0
            
    return S_corr_np
            
def scalar_vector_correlation(double [::1] delta,
                              double [::1] Sx,
                              double [::1] Sy,
                              double [::1] Sz,
                              double [::1] rx,
                              double [::1] ry,
                              double [::1] rz,
                              signed long long [::1] counts,
                              signed long long [::1] search,
                              long long [:,::1] coordinate):
    
    cdef Py_ssize_t N = counts.shape[0]
    
    S_corr_np = np.zeros(N+1)
    S_corr_np[N] = 1
    
    cdef double [::1] S_corr = S_corr_np
    
    cdef Py_ssize_t r, s, i, j
    
    cdef double rx_ij, ry_ij, rz_ij, Sx_ij, Sy_ij, Sz_ij
    
    cdef double U, V, metric
    
    cdef Py_ssize_t count

    for r in range(N):
        
        count = counts[r]
        
        for s in range(search[r],search[r+1]):
            
            i, j = coordinate[s,0], coordinate[s,1]
            
            rx_ij = rx[j]-rx[i]
            ry_ij = ry[j]-ry[i]
            rz_ij = rz[j]-rz[i]
            
            Sx_ij = Sx[j]-Sx[i]
            Sy_ij = Sy[j]-Sy[i]
            Sz_ij = Sz[j]-Sz[i]
            
            U = sqrt(rx_ij*rx_ij+ry_ij*ry_ij+rz_ij*rz_ij)
            V = sqrt(Sx_ij*Sx_ij+Sy_ij*Sy_ij+Sz_ij*Sz_ij)
            
            metric = delta[i]*(1-delta[j])+delta[j]*(1-delta[i])
            
            if (not (iszero(U) or iszero(V)) and metric > 0.5):   
                S_corr[r] += (rx_ij*Sx_ij+ry_ij*Sy_ij+rz_ij*Sz_ij)/U/V
            else:
                count -= 1
                
        if (count > 0):
            S_corr[r] /= count
        else:
            S_corr[r] = 0
            
    return S_corr_np

def pairs1d(rx, ry, rz, ion, nu, nv, nw, fract=0.25, tol=1e-4):

    n_atm = ion.shape[0] // (nu*nv*nw)
    
    mu = (nu+1) // 2
    mv = (nv+1) // 2
    mw = (nw+1) // 2
        
    m_uvw = mu*mv*mw
    n_uvw = nu*nv*nw
    
    m_xyz = mu*mv*mw*n_atm
    n_xyz = nu*nv*nw*n_atm
        
    c_uvw = np.arange(n_uvw, dtype=int)
                    
    cu, cv, cw = np.unravel_index(c_uvw, (nu,nv,nw))
        
    i_lat, j_lat = np.triu_indices(m_uvw, k=1)
    
    iu, iv, iw = np.unravel_index(i_lat, (mu,mv,mw))
    ju, jv, jw = np.unravel_index(j_lat, (mu,mv,mw))
    
    iu = np.mod(iu+cu[:,None], nu)
    iv = np.mod(iv+cv[:,None], nv)
    iw = np.mod(iw+cw[:,None], nw)
    
    ju = np.mod(ju+cu[:,None], nu)
    jv = np.mod(jv+cv[:,None], nv)
    jw = np.mod(jw+cw[:,None], nw)
    
    i_lat = np.ravel_multi_index((iu,iv,iw), (nu,nv,nw))
    j_lat = np.ravel_multi_index((ju,jv,jw), (nu,nv,nw))
    
    pairs = np.stack((i_lat,j_lat)).reshape(2,n_uvw*m_uvw*(m_uvw-1)//2)
        
    i_lat, j_lat = np.unique(np.sort(pairs, axis=0), axis=1)
    
    i_atm, j_atm = np.triu_indices(n_atm, k=1)
    
    i_atms = np.concatenate((i_atm,j_atm))
    j_atms = np.concatenate((j_atm,i_atm))
   
    i_atms = np.concatenate((i_atms,np.arange(n_atm)))
    j_atms = np.concatenate((j_atms,np.arange(n_atm)))
   
    i = np.ravel_multi_index((i_lat,i_atms[:,None]), (n_uvw,n_atm)).flatten()
    j = np.ravel_multi_index((j_lat,j_atms[:,None]), (n_uvw,n_atm)).flatten()
    
    ic = np.ravel_multi_index((c_uvw,i_atm[:,None]), (n_uvw,n_atm)).flatten()
    jc = np.ravel_multi_index((c_uvw,j_atm[:,None]), (n_uvw,n_atm)).flatten()
        
    i, j = np.concatenate((i,ic)), np.concatenate((j,jc))
    
    dx = rx[j]-rx[i]
    dy = ry[j]-ry[i]
    dz = rz[j]-rz[i]
    
    distance = np.sqrt(dx**2+dy**2+dz**2)
        
    mask = distance <= distance.max()*fract
    
    dx = dx[mask]
    dy = dy[mask]
    dz = dz[mask]
    distance = distance[mask]
    
    i = i[mask]
    j = j[mask]
    
    coordinate = np.column_stack((i,j))
    
    atms = np.sort(np.stack((ion[j],ion[i])), axis=0)
        
    ion_ion = np.core.defchararray.add( \
              np.core.defchararray.add(atms[0,:], '_'), atms[1,:])
        
    ions, ion_labels = np.unique(ion_ion, return_inverse=True)
        
    metric = np.stack((np.round(np.round(distance/tol,1)).astype(int), \
                       ion_labels)).T
                            
    sort = np.lexsort(np.fliplr(metric).T)
        
    distance = distance[sort]
    coordinate[:,0] = i[sort]
    coordinate[:,1] = j[sort]
    
    ion_ion = ion_ion[sort]
    
    metric = metric[sort]
    
    unique, indices, counts = np.unique(metric, 
                                        axis=0,
                                        return_index=True, 
                                        return_counts=True)
    
    search = np.append(indices,len(distance))
    
    distance = distance[indices]                   
    ion_pair = ion_ion[indices]
    
    distance = np.append(distance, 0)
    ion_pair = np.append(ion_pair, '0')
    
    return distance, ion_pair, counts, search, coordinate, unique.shape[0]+1

def pairs3d(rx, ry, rz, ion, nu, nv, nw, fract=0.25, tol=1e-4):
    
    n_atm = ion.shape[0] // (nu*nv*nw)
    
    mu = (nu+1) // 2
    mv = (nv+1) // 2
    mw = (nw+1) // 2
        
    m_uvw = mu*mv*mw
    n_uvw = nu*nv*nw
    
    m_xyz = mu*mv*mw*n_atm
    n_xyz = nu*nv*nw*n_atm
        
    c_uvw = np.arange(n_uvw, dtype=int)
                    
    cu, cv, cw = np.unravel_index(c_uvw, (nu,nv,nw))
        
    i_lat, j_lat = np.triu_indices(m_uvw, k=1)
    
    iu, iv, iw = np.unravel_index(i_lat, (mu,mv,mw))
    ju, jv, jw = np.unravel_index(j_lat, (mu,mv,mw))
    
    iu = np.mod(iu+cu[:,None], nu)
    iv = np.mod(iv+cv[:,None], nv)
    iw = np.mod(iw+cw[:,None], nw)
    
    ju = np.mod(ju+cu[:,None], nu)
    jv = np.mod(jv+cv[:,None], nv)
    jw = np.mod(jw+cw[:,None], nw)
    
    i_lat = np.ravel_multi_index((iu,iv,iw), (nu,nv,nw))
    j_lat = np.ravel_multi_index((ju,jv,jw), (nu,nv,nw))
    
    pairs = np.stack((i_lat,j_lat)).reshape(2,n_uvw*m_uvw*(m_uvw-1)//2)
        
    i_lat, j_lat = np.unique(np.sort(pairs, axis=0), axis=1)
    
    i_atm, j_atm = np.triu_indices(n_atm, k=1)
    
    i_atms = np.concatenate((i_atm,j_atm))
    j_atms = np.concatenate((j_atm,i_atm))
   
    i_atms = np.concatenate((i_atms,np.arange(n_atm)))
    j_atms = np.concatenate((j_atms,np.arange(n_atm)))
   
    i = np.ravel_multi_index((i_lat,i_atms[:,None]), (n_uvw,n_atm)).flatten()
    j = np.ravel_multi_index((j_lat,j_atms[:,None]), (n_uvw,n_atm)).flatten()
    
    ic = np.ravel_multi_index((c_uvw,i_atm[:,None]), (n_uvw,n_atm)).flatten()
    jc = np.ravel_multi_index((c_uvw,j_atm[:,None]), (n_uvw,n_atm)).flatten()
    
    i, j = np.concatenate((i,ic)), np.concatenate((j,jc))
        
    dx = rx[j]-rx[i]
    dy = ry[j]-ry[i]
    dz = rz[j]-rz[i]
    
    distance = np.sqrt(dx**2+dy**2+dz**2)
            
    mask = distance <= distance.max()*fract
    
    dx = dx[mask]
    dy = dy[mask]
    dz = dz[mask]
    distance = distance[mask]
    
    i = i[mask]
    j = j[mask]
    
    coordinate = np.column_stack((i,j))
    
    atms = np.sort(np.stack((ion[j],ion[i])), axis=0)

    ion_ion = np.core.defchararray.add( \
              np.core.defchararray.add(atms[0,:], '_'), atms[1,:])
        
    ions, ion_labels = np.unique(ion_ion, return_inverse=True)
        
    metric = np.vstack((np.round(np.round(distance.T/tol,1)).astype(int), \
                        ion_labels)).T
    
    sort = np.lexsort(np.fliplr(metric).T)
        
    distance = distance[sort]
    coordinate[:,0] = i[sort]
    coordinate[:,1] = j[sort]
    
    ion_ion = ion_ion[sort]
    
    metric = metric[sort]

    unique, indices, counts = np.unique(metric, 
                                        axis=0,
                                        return_index=True, 
                                        return_counts=True)
            
    search = np.append(indices,len(distance))
    
    dx = dx[sort][indices]
    dy = dy[sort][indices]
    dz = dz[sort][indices]
    ion_pair = ion_ion[indices]
    
    dx = np.append(dx, 0)
    dy = np.append(dy, 0)
    dz = np.append(dz, 0)
    ion_pair = np.append(ion_pair, '0')
    
    return dx, dy, dz, ion_pair, counts, search, coordinate, unique.shape[0]+1

def vector1d(Sx, Sy, Sz, rx, ry, rz, ion, nu, nv, nw, fract=0.25, tol=1e-4):
    
    data = pairs1d(rx, ry, rz, ion, nu, nv, nw, fract, tol)
    
    distance, ion_pair, counts, search, coordinate, N = data
    
    S_corr  = vector_correlation(Sx, Sy, Sz, counts, search, coordinate)
    S_coll  = vector_collinearity(Sx, Sy, Sz, counts, search, coordinate)
    S_corr_ = vector_average(Sx, Sy, Sz, counts, search, coordinate)
    
    S_coll_ = S_corr**2
             
    return S_corr, S_coll, S_corr_, S_coll_, distance, ion_pair

def vector3d(Sx, Sy, Sz, rx, ry, rz, ion, nu, nv, nw, fract=0.25, tol=1e-4):
    
    data = pairs3d(rx, ry, rz, ion, nu, nv, nw, fract, tol)
    
    dx, dy, dz, ion_pair, counts, search, coordinate, N = data
                       
    S_corr  = vector_correlation(Sx, Sy, Sz, counts, search, coordinate)
    S_coll  = vector_collinearity(Sx, Sy, Sz, counts, search, coordinate)
    S_corr_ = vector_average(Sx, Sy, Sz, counts, search, coordinate)

    S_coll_ = S_corr**2
    
    dx = np.concatenate((dx,-dx[:N-1]))
    dy = np.concatenate((dy,-dy[:N-1]))
    dz = np.concatenate((dz,-dz[:N-1]))
    
    ion_pair = np.concatenate((ion_pair,ion_pair[:N-1]))
    
    S_corr  = np.concatenate((S_corr,S_corr[:N-1]))
    S_coll  = np.concatenate((S_coll,S_coll[:N-1]))
    S_corr_ = np.concatenate((S_corr_,S_corr_[:N-1]))
    S_coll_ = np.concatenate((S_coll_,S_coll_[:N-1]))
                 
    return S_corr, S_coll, S_corr_, S_coll_, dx, dy, dz, ion_pair

def scalar1d(A_r, rx, ry, rz, ion, nu, nv, nw, fract=0.25, tol=1e-4):
    
    data = pairs1d(rx, ry, rz, ion, nu, nv, nw, fract, tol)
    
    distance, ion_pair, counts, search, coordinate, N = data
                        
    S_corr  = scalar_correlation(A_r, counts, search, coordinate)
    S_corr_ = scalar_average(A_r, counts, search, coordinate)
         
    return S_corr, S_corr_, distance, ion_pair
           
def scalar3d(A_r, rx, ry, rz, ion, nu, nv, nw, fract=0.25, tol=1e-4):
    
    data = pairs3d(rx, ry, rz, ion, nu, nv, nw, fract, tol)
    
    dx, dy, dz, ion_pair, counts, search, coordinate, N = data
                   
    S_corr  = scalar_correlation(A_r, counts, search, coordinate)
    S_corr_ = scalar_average(A_r, counts, search, coordinate)
    
    dx = np.concatenate((dx,-dx[:N-1]))
    dy = np.concatenate((dy,-dy[:N-1]))
    dz = np.concatenate((dz,-dz[:N-1]))
    
    ion_pair = np.concatenate((ion_pair,ion_pair[:N-1]))
    
    S_corr  = np.concatenate((S_corr,S_corr[:N-1]))
    S_corr_ = np.concatenate((S_corr_,S_corr_[:N-1]))
    
    return S_corr, S_corr_, dx, dy, dz, ion_pair
           
def combination1d(delta, Sx, Sy, Sz, rx, ry, rz, ion, \
                  nu, nv, nw, fract=0.25, tol=1e-4):
    
    data = pairs1d(rx, ry, rz, ion, nu, nv, nw, fract, tol)
    
    distance, ion_pair, counts, search, coordinate, N = data
        
    S_corr = scalar_vector_correlation(delta, Sx, Sy, Sz, rx, ry, rz,
                                       counts, search, coordinate)
         
    return S_corr, distance, ion_pair
           
def combination3d(delta, Sx, Sy, Sz, rx, ry, rz, \
                  ion, nu, nv, nw, fract=0.25, tol=1e-4):
    
    data = pairs3d(rx, ry, rz, ion, nu, nv, nw, fract, tol)
    
    dx, dy, dz, ion_pair, counts, search, coordinate, N = data
        
    S_corr = scalar_vector_correlation(delta, Sx, Sy, Sz, rx, ry, rz,
                                       counts, search, coordinate)
    
    dx = np.concatenate((dx,-dx[:N-1]))
    dy = np.concatenate((dy,-dy[:N-1]))
    dz = np.concatenate((dz,-dz[:N-1]))
    
    ion_pair = np.concatenate((ion_pair,ion_pair[:N-1]))
    
    S_corr  = np.concatenate((S_corr,S_corr[:N-1]))
    
    return S_corr, dx, dy, dz, ion_pair