#!/usr/bin/env python

# Copyright (C) 2017 Alexander Blinne <A.Blinne@gsi.de>,
# Stephan Kuschel <Stephan.Kuschel@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os.path as osp
import unittest
import platform

import numpy as np
import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
import sdf

from . import SimTest


micron = 1e-6
femto = 1e-15
c = 2.99792458e8  # m/s

# check that these correspond to input deck!

nx = 240

x_min = -12 * micron
x_max = -x_min

dt_multiplier = 0.95

lambda_l = 0.5 * micron
x0 = -12.0 * micron  # m
t0 = 8 * femto  # s

# derived quantities from the above
k_l = 2*np.pi/lambda_l
dx = (x_max-x_min)/nx

dt_yee = dt_multiplier * dx / c

vg_lehe = c*(1.0 + 2.0*(1.0-c*dt_yee/dx)*(k_l*dx/2.0)**2)
vg_yee = c*np.cos(k_l*dx/2.0)/np.sqrt(1-(c*dt_yee/dx*np.sin(k_l*dx/2.0))**2)


def xt(sdffile, key='Electric Field/Ey'):
    t = sdffile['Header']['time']
    xaxis = sdffile[key].grid_mid.data[0]
    data = sdffile[key].data
    b = np.sum(data**2)
    if b > 0 and t > 0:
        x = np.sum(xaxis*data**2)/b
    else:
        x = None

    return t, x


class test_maxwell_solvers(SimTest):
    solvers = ['yee', 'lehe_x']

    @classmethod
    def setUpClass(cls):
        super(test_maxwell_solvers, cls).setUpClass()

        dumps = cls.dumps = {}
        for solver in cls.solvers:
            l = dumps.setdefault(solver, [])
            for dump in [osp.join(solver, '{:04d}.sdf'.format(i))
                         for i in range(8)]:
                l.append(sdf.read(dump, dict=True))

    def test_createplot(self):
        if platform.system() == 'Darwin':
            print('macosx backend')
            plt.switch_backend('macosx')

        key = 'Electric Field/Ey'
        fig, axarr = plt.subplots(2, 4, figsize=(16, 9))

        for i, ax in enumerate(np.ravel(axarr)):
            dump0 = self.dumps[self.solvers[0]][i]
            axis = dump0[key].grid_mid.data[0]*1e6
            for solver in self.solvers:
                array = self.dumps[solver][i][key].data
                ax.plot(axis, array, label=solver, linewidth=1)
            ax.set_title('{:2.1f} fs'.format(dump0['Header']['time']*1e15))
            ax.set_xlabel(r'x [${\mu}\mathrm{m}$]')
            ax.legend(loc='best')

        fig.suptitle(key)

        fig.tight_layout()
        fig.savefig(key.replace('/', '_') + '.png', dpi=320)

    def test_group_velocity(self):
        tx = {}
        for solver in self.solvers:
            tx[solver] = np.array([xt(dump)
                                   for dump in self.dumps[solver][1:]])
        print(tx)

        vg = dict(lehe_x=vg_lehe, yee=vg_yee)

        for solver, data in tx.items():
            vg_sim = np.polyfit(data[:, 0], data[:, 1], 1)[0]

            # For reference, right here, right now the following line prints
            # yee 291329547.371 292363351.796 0.00353602604066
            # lehe_x 310055314.605 311627789.85156083 0.00504600455477
            print(solver, vg_sim, vg[solver],
                  abs(vg_sim-vg[solver])/vg[solver])

            assert np.isclose(vg_sim, vg[solver], rtol=0.01)


if __name__ == '__main__':
    unittest.main()
