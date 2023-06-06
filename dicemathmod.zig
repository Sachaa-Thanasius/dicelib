const dicemath = @import("dicemath.zig");

const c = @cImport({
    @cDefine("PY_SSIZE_T_CLEAN", "1");
    @cInclude("Python.h");
});

const PyObject = c.PyObject;

const PyModuleDef_Base = extern struct {
    ob_base: PyObject,
    m_init: ?*const fn () callconv(.C) [*c]PyObject = null,
    m_index: c.Py_ssize_t = 0,
    m_copy: [*c]PyObject = null,
};

const PyModuleDef_HEAD_INIT = PyModuleDef_Base{ .ob_base = PyObject{
    .ob_refcnt = 1,
    .ob_type = null,
} };

const PyMethodDef = extern struct {
    ml_name: [*c]const u8 = null,
    ml_meth: c.PyCFunction = null,
    ml_flags: c_int = 0,
    ml_doc: [*c]const u8 = null,
};

const PyModuleDef = extern struct {
    m_base: PyModuleDef_Base = PyModuleDef_HEAD_INIT,
    m_name: [*c]const u8,
    m_doc: [*c]const u8 = null,
    m_size: c.Py_ssize_t = -1,
    m_methods: [*]PyMethodDef,
    m_slots: [*c]c.struct_PyModuleDef_Slot = null,
    m_traverse: c.traverseproc = null,
    m_clear: c.inquiry = null,
    m_free: c.freefunc = null,
};

pub export fn py_ev_xdy_keep_best_n(self: [*]PyObject, args: [*]PyObject) [*c]PyObject {
    var x: c_uint = undefined;
    var y: c_uint = undefined;
    var n: c_uint = undefined;
    _ = self;
    if (!(c._PyArg_ParseTuple_SizeT(args, "III", &x, &y, &n) != 0)) return null;
    return c.PyFloat_FromDouble(dicemath.ev_xdy_keep_best_n(x, y, n));
}

pub export fn py_ev_xdy_keep_worst_n(self: [*]PyObject, args: [*]PyObject) [*c]PyObject {
    var x: c_uint = undefined;
    var y: c_uint = undefined;
    var n: c_uint = undefined;
    _ = self;
    if (!(c._PyArg_ParseTuple_SizeT(args, "III", &x, &y, &n) != 0)) return null;
    return c.PyFloat_FromDouble(dicemath.ev_xdy_keep_worst_n(x, y, n));
}

pub var methods = [_:PyMethodDef{}]PyMethodDef{
    PyMethodDef{
        .ml_name = "ev_xdy_keep_best_n",
        .ml_meth = @ptrCast(c.PyCFunction, @alignCast(@import("std").meta.alignment(c.PyCFunction), &py_ev_xdy_keep_best_n)),
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
    PyMethodDef{
        .ml_name = "ev_xdy_keep_worst_n",
        .ml_meth = @ptrCast(c.PyCFunction, @alignCast(@import("std").meta.alignment(c.PyCFunction), &py_ev_xdy_keep_worst_n)),
        .ml_flags = @as(c_int, 1),
        .ml_doc = null,
    },
};

pub var zigmodule = PyModuleDef{
    .m_name = "dicemath",
    .m_methods = &methods,
};

pub export fn PyInit_dicemath() [*c]c.PyObject {
    return c.PyModule_Create(@ptrCast([*c]c.struct_PyModuleDef, &zigmodule));
}
